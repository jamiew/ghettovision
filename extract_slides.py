#!/usr/bin/env python3
"""
Extract images from Google Slides, PDF, or PPTX files for use with pummelize.

Usage:
    # Google Slides (requires rclone configured with Google Drive)
    python extract_slides.py "https://docs.google.com/presentation/d/1ABC.../edit"

    # Local files
    python extract_slides.py input.pdf [output_dir]
    python extract_slides.py presentation.pptx [output_dir]

Requires:
    pip install pdf2image Pillow
    brew install poppler rclone
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def check_rclone_configured(remote: str = "gdrive") -> bool:
    """Check if rclone remote is configured."""
    try:
        result = subprocess.run(
            ["rclone", "listremotes"],
            capture_output=True,
            text=True,
            check=True,
        )
        return f"{remote}:" in result.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def parse_google_slides_url(url: str) -> str | None:
    """Extract presentation ID from a Google Slides URL."""
    # Matches URLs like:
    # https://docs.google.com/presentation/d/1ABC123.../edit
    # https://docs.google.com/presentation/d/1ABC123.../edit?usp=sharing
    pattern = r"docs\.google\.com/presentation/d/([a-zA-Z0-9_-]+)"
    match = re.search(pattern, url)
    return match.group(1) if match else None


def extract_from_google_slides(
    url: str, output_dir: Path, dpi: int = 150, remote: str = "gdrive"
) -> int:
    """Download Google Slides as PDF via rclone, then extract images."""
    presentation_id = parse_google_slides_url(url)
    if not presentation_id:
        print(f"Error: Could not parse Google Slides URL: {url}")
        sys.exit(1)

    if not check_rclone_configured(remote):
        print(f"Error: rclone remote '{remote}' not configured.")
        print("Run: rclone config")
        print("  - Choose 'n' for new remote")
        print("  - Name it 'gdrive'")
        print("  - Choose 'drive' for Google Drive")
        print("  - Follow the OAuth prompts")
        sys.exit(1)

    with tempfile.TemporaryDirectory() as tmpdir:
        print(f"Downloading slides via rclone...")

        # Use rclone to export the presentation as PDF
        # --drive-root-folder-id treats the file ID as the root
        result = subprocess.run(
            [
                "rclone",
                "copy",
                f"{remote}:",
                tmpdir,
                f"--drive-root-folder-id={presentation_id}",
                "--drive-export-formats=pdf",
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            print(f"Error: rclone failed: {result.stderr}")
            sys.exit(1)

        # Find the downloaded PDF
        pdf_files = list(Path(tmpdir).glob("*.pdf"))
        if not pdf_files:
            print("Error: No PDF downloaded. Check that the URL is correct and accessible.")
            print(f"Presentation ID: {presentation_id}")
            sys.exit(1)

        print(f"Downloaded: {pdf_files[0].name}")
        return extract_from_pdf(pdf_files[0], output_dir, dpi=dpi)


def extract_from_pdf(pdf_path: Path, output_dir: Path, dpi: int = 150) -> int:
    """Extract each page of a PDF as a JPEG image."""
    try:
        from pdf2image import convert_from_path
    except ImportError:
        print("Error: pdf2image not installed. Run: pip install pdf2image")
        print("Also need poppler: brew install poppler")
        sys.exit(1)

    print(f"Extracting pages from {pdf_path.name}...")
    pages = convert_from_path(pdf_path, dpi=dpi)

    for i, page in enumerate(pages, start=1):
        output_path = output_dir / f"slide_{i:04d}.jpg"
        page.save(output_path, "JPEG", quality=95)
        print(f"  {output_path.name}")

    return len(pages)


def extract_from_pptx(pptx_path: Path, output_dir: Path, dpi: int = 150) -> int:
    """Extract slides from PPTX as images via LibreOffice."""
    soffice_paths = [
        "/Applications/LibreOffice.app/Contents/MacOS/soffice",
        "soffice",
        "libreoffice",
    ]

    soffice = None
    for path in soffice_paths:
        try:
            subprocess.run([path, "--version"], capture_output=True, check=True)
            soffice = path
            break
        except (subprocess.CalledProcessError, FileNotFoundError):
            continue

    if not soffice:
        print("Error: LibreOffice not found. Install it for PPTX support.")
        print("  brew install --cask libreoffice")
        sys.exit(1)

    with tempfile.TemporaryDirectory() as tmpdir:
        print(f"Converting {pptx_path} to PDF...")
        subprocess.run(
            [soffice, "--headless", "--convert-to", "pdf", "--outdir", tmpdir, str(pptx_path)],
            check=True,
            capture_output=True,
        )

        pdf_files = list(Path(tmpdir).glob("*.pdf"))
        if not pdf_files:
            print("Error: Failed to convert PPTX to PDF")
            sys.exit(1)

        return extract_from_pdf(pdf_files[0], output_dir, dpi=dpi)


def main():
    parser = argparse.ArgumentParser(
        description="Extract slides from Google Slides, PDF, or PPTX as images"
    )
    parser.add_argument(
        "input",
        help="Google Slides URL, or path to PDF/PPTX file",
    )
    parser.add_argument(
        "output_dir",
        type=Path,
        nargs="?",
        default=None,
        help="Output directory (default: ./slides)",
    )
    parser.add_argument(
        "--dpi",
        type=int,
        default=150,
        help="DPI for rendering (default: 150, higher = larger images)",
    )
    parser.add_argument(
        "--remote",
        default="gdrive",
        help="rclone remote name for Google Drive (default: gdrive)",
    )

    args = parser.parse_args()

    output_dir = args.output_dir or Path("./slides")
    output_dir.mkdir(parents=True, exist_ok=True)

    # Check if input is a Google Slides URL
    if "docs.google.com/presentation" in args.input:
        count = extract_from_google_slides(
            args.input, output_dir, dpi=args.dpi, remote=args.remote
        )
    else:
        # Treat as local file
        input_path = Path(args.input)
        if not input_path.exists():
            print(f"Error: {input_path} not found")
            sys.exit(1)

        suffix = input_path.suffix.lower()
        if suffix == ".pdf":
            count = extract_from_pdf(input_path, output_dir, dpi=args.dpi)
        elif suffix in (".pptx", ".ppt"):
            count = extract_from_pptx(input_path, output_dir, dpi=args.dpi)
        else:
            print(f"Error: Unsupported file type: {suffix}")
            print("Supported: Google Slides URL, .pdf, .pptx, .ppt")
            sys.exit(1)

    print(f"\nExtracted {count} slides to {output_dir}/")
    print(f"Now run: ./pummelize.sh {output_dir}")


if __name__ == "__main__":
    main()
