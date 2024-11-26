import os
import subprocess
from datetime import datetime

def sanitize_filename(filename):
    """Sanitize the filename by replacing special characters."""
    return filename.replace("/", "_").replace(":", "_")

def format_results_with_nmap_formatter(xml_file, output_dir):
    """Convert an nmap .xml file to .md and .d2 formats."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_name = os.path.splitext(os.path.basename(xml_file))[0]
    sanitized_name = sanitize_filename(base_name)
    
    print(f"Processing XML file: {xml_file}")
    try:
        # Generate Markdown output
        md_output = os.path.join(output_dir, f"{sanitized_name}_{timestamp}.md")
        subprocess.run([
            "nmap-formatter", "md", "-f", md_output, xml_file
        ], check=True)
        print(f"Markdown results saved as {md_output}")

        # Generate D2 output
        d2_output = os.path.join(output_dir, f"{sanitized_name}_{timestamp}.d2")
        subprocess.run([
            "nmap-formatter", "d2", "-f", d2_output, xml_file
        ], check=True)
        print(f"D2 results saved as {d2_output}")

        # Render D2 to PNG
        render_d2_to_png(d2_output, output_dir)

    except subprocess.CalledProcessError as e:
        print(f"Error processing {xml_file}: {e}")

def render_d2_to_png(d2_file, output_dir):
    """Render a .d2 file into a .png file."""
    png_file = os.path.join(output_dir, os.path.splitext(os.path.basename(d2_file))[0] + ".png")
    print(f"Rendering D2 file {d2_file} to PNG...")
    try:
        subprocess.run([
            "d2", d2_file, png_file
        ], check=True)
        print(f"PNG image saved as {png_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error rendering D2 to PNG: {e}")

def process_nmap_scans(start_dir):
    """Recursively search for .xml files and process them."""
    for root, _, files in os.walk(start_dir):
        for file in files:
            if file.endswith(".xml"):
                xml_file = os.path.join(root, file)
                output_dir = root  # Save outputs in the same directory as the XML file
                format_results_with_nmap_formatter(xml_file, output_dir)

def main():
    start_dir = input("Enter the starting directory to search for nmap XML files: ").strip()
    if not os.path.exists(start_dir):
        print(f"Directory does not exist: {start_dir}")
        return

    print(f"Searching for nmap XML files in {start_dir} and processing them...")
    process_nmap_scans(start_dir)
    print("Processing complete!")

if __name__ == "__main__":
    main()
