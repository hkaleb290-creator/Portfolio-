from pdf2image import convert_from_path
import os

pdf_path = "aerospace_report (3).pdf"
output_dir = "."

# Convert PDF to images
print(f"Converting PDF to images...")
images = convert_from_path(pdf_path, dpi=150)

print(f"Found {len(images)} pages in PDF")

# Save first 8 images as gallery photos
for i, image in enumerate(images[:8], 1):
    output_file = f"uav_photo_{i}.jpg"
    image.save(output_file, "JPEG", quality=85)
    print(f"Saved {output_file}")

print("✓ Image extraction complete!")
