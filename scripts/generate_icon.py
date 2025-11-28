#!/usr/bin/env python3
"""
Diaspora Handbook Icon Generator
Creates a custom app icon with "DH" (D=purple, H=yellow/gold)
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon():
    print("🎨 Generating Diaspora Handbook icon...")
    
    # Icon size
    size = 1024
    
    # Create image with WHITE background
    img = Image.new('RGB', (size, size), color='#FFFFFF')
    draw = ImageDraw.Draw(img)
    
    # Draw subtle sun rays in corner (decorative) - light gold on white
    import math
    ray_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    ray_draw = ImageDraw.Draw(ray_img)
    
    for i in range(8):
        angle = i * 45
        x1, y1 = size * 0.15, size * 0.15
        length = 150 if i % 2 == 0 else 100
        x2 = x1 + length * math.cos(math.radians(angle))
        y2 = y1 + length * math.sin(math.radians(angle))
        # Light gold rays on white background
        ray_draw.line([(x1, y1), (x2, y2)], fill=(255, 215, 0, 60), width=10)
    
    img = Image.alpha_composite(img.convert('RGBA'), ray_img).convert('RGB')
    draw = ImageDraw.Draw(img)
    
    # Add rounded corners (iOS style)
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=int(size * 0.22), fill=255)
    
    # Apply mask
    output = Image.new('RGB', (size, size), (255, 255, 255))
    output.paste(img, (0, 0))
    img_with_mask = Image.new('RGBA', (size, size))
    img_with_mask.paste(output, (0, 0))
    img_with_mask.putalpha(mask)
    
    # Convert back to RGB for final output
    final_img = Image.new('RGB', (size, size), (255, 255, 255))
    final_img.paste(img_with_mask, (0, 0), img_with_mask)
    draw = ImageDraw.Draw(final_img)
    
    # Try to use a bold system font
    try:
        # Try different font options
        font_size = int(size * 0.55)
        font_paths = [
            '/System/Library/Fonts/Helvetica.ttc',
            '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
            '/Library/Fonts/Arial Bold.ttf',
            'Arial',
        ]
        
        font = None
        for font_path in font_paths:
            try:
                if os.path.exists(font_path):
                    font = ImageFont.truetype(font_path, font_size)
                    break
            except:
                continue
        
        if not font:
            # Fallback to default
            font = ImageFont.load_default()
            font_size = 200  # Approximate size for default font
            
    except Exception as e:
        print(f"Warning: Could not load custom font: {e}")
        font = ImageFont.load_default()
        font_size = 200
    
    # Draw "D" in purple
    d_color = (155, 89, 182)  # Purple #9B59B6
    h_color = (255, 215, 0)   # Gold #FFD700
    
    # Calculate text positioning
    text = "DH"
    
    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center position
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 40  # Slightly above center
    
    # Draw shadow for depth (lighter shadow for white background)
    shadow_offset = 6
    draw.text((x + shadow_offset, y + shadow_offset), "D", font=font, fill=(200, 200, 200))
    draw.text((x + text_width//2 + shadow_offset, y + shadow_offset), "H", font=font, fill=(200, 200, 200))
    
    # Draw the letters
    draw.text((x, y), "D", font=font, fill=d_color)
    
    # Get width of "D" to position "H"
    d_bbox = draw.textbbox((x, y), "D", font=font)
    d_width = d_bbox[2] - d_bbox[0]
    
    draw.text((x + d_width - 30, y), "H", font=font, fill=h_color)  # Overlap slightly
    
    # Add tagline
    try:
        tagline_font_size = int(size * 0.035)
        tagline_font = ImageFont.truetype(font_paths[0], tagline_font_size) if os.path.exists(font_paths[0]) else font
    except:
        tagline_font = font
    
    tagline = "HOMECOMING GUIDE"
    tagline_bbox = draw.textbbox((0, 0), tagline, font=tagline_font)
    tagline_width = tagline_bbox[2] - tagline_bbox[0]
    tagline_x = (size - tagline_width) // 2
    tagline_y = int(size * 0.85)
    
    # Draw tagline in darker color for visibility on white
    draw.text((tagline_x, tagline_y), tagline, font=tagline_font, fill=(155, 89, 182))
    
    # Draw subtle border (lighter for white background)
    border_width = 3
    draw.rounded_rectangle(
        [(border_width, border_width), (size - border_width, size - border_width)],
        radius=int(size * 0.22),
        outline=(230, 230, 230),
        width=border_width
    )
    
    # Save the icon
    output_path = 'assets/icon.png'
    final_img.save(output_path, 'PNG', quality=100)
    
    print(f"✅ Icon generated successfully: {output_path}")
    print(f"   Size: {size}x{size} pixels")
    print(f"   Colors: Purple 'D' (#9B59B6) + Gold 'H' (#FFD700)")
    print("")
    print("Next steps:")
    print("  1. Run: flutter pub run flutter_launcher_icons")
    print("  2. Run: flutter clean && flutter run")

if __name__ == "__main__":
    create_icon()

