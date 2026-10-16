#!/usr/bin/env python3
"""Draws the placeholder app icon and writes every platform's sizes.

The painted icon is not delivered yet (build-spec section 9, T-27). Until it is,
this draws a lacquer tablet with a gold border, the monogram "LK" and a
cinnabar seal. When the artist's master is ready, save it as
tools/icons/master.png (1024x1024, square, no transparency) and run

    python3 tools/icons/make_icons.py --master tools/icons/master.png

to resize it into the platform folders. Needs Pillow (`pip install pillow`).
"""
import argparse
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
APP = os.path.join(ROOT, 'apps', 'game')
FONT = os.path.join(APP, 'assets', 'fonts', 'BeVietnamPro', 'BeVietnamPro-Bold.ttf')

LACQUER = (14, 11, 10)
GOLD = (201, 162, 74)
CINNABAR = (179, 38, 30)
IVORY = (242, 232, 213)


def draw_master(size=1024):
    """Square, full bleed (iOS and Android crop it themselves)."""
    img = Image.new('RGB', (size, size), LACQUER)
    d = ImageDraw.Draw(img)
    u = size / 1024
    # Double gold border, like the frame of a lacquer tablet.
    d.rectangle([60 * u, 60 * u, size - 60 * u, size - 60 * u], outline=GOLD, width=int(14 * u))
    d.rectangle([100 * u, 100 * u, size - 100 * u, size - 100 * u], outline=GOLD, width=int(5 * u))
    font = ImageFont.truetype(FONT, int(430 * u))
    text = 'LK'
    box = d.textbbox((0, 0), text, font=font)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text(((size - w) / 2 - box[0], (size - h) / 2 - box[1] - 50 * u), text, font=font, fill=GOLD)
    # A seal in the lower right corner.
    s = 150 * u
    x1, y1 = size - 190 * u, size - 190 * u
    d.rectangle([x1 - s, y1 - s, x1, y1], fill=CINNABAR)
    d.rectangle([x1 - s + 12 * u, y1 - s + 12 * u, x1 - 12 * u, y1 - 12 * u], outline=IVORY, width=int(5 * u))
    seal = ImageFont.truetype(FONT, int(90 * u))
    sb = d.textbbox((0, 0), 'Ký', font=seal)
    d.text((x1 - s / 2 - (sb[2] - sb[0]) / 2 - sb[0], y1 - s / 2 - (sb[3] - sb[1]) / 2 - sb[1]), 'Ký', font=seal, fill=IVORY)
    return img


def mac_icon(master, size):
    """macOS style: the tablet on a transparent ground with rounded corners."""
    inner = int(size * 0.8125)
    art = master.resize((inner, inner), Image.LANCZOS).convert('RGBA')
    mask = Image.new('L', (inner, inner), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, inner, inner], radius=int(inner * 0.225), fill=255)
    art.putalpha(mask)
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(art, ((size - inner) // 2, (size - inner) // 2), art)
    return out


def save(img, path, size):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--master', help='a 1024x1024 PNG to use instead of the drawn placeholder')
    args = ap.parse_args()
    master = Image.open(args.master).convert('RGB') if args.master else draw_master()
    if master.size != (1024, 1024):
        sys.exit('the master must be 1024x1024')
    master.save(os.path.join(os.path.dirname(__file__), 'master.png'))

    # Android: legacy launcher icons.
    for folder, px in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
        save(master, os.path.join(APP, 'android/app/src/main/res', f'mipmap-{folder}', 'ic_launcher.png'), px)

    # iOS: sizes from the asset catalog itself, no transparency.
    ios = os.path.join(APP, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
    for item in json.load(open(os.path.join(ios, 'Contents.json')))['images']:
        points = float(item['size'].split('x')[0])
        px = round(points * int(item['scale'].rstrip('x')))
        save(master, os.path.join(ios, item['filename']), px)

    # macOS.
    mac = os.path.join(APP, 'macos/Runner/Assets.xcassets/AppIcon.appiconset')
    for px in (16, 32, 64, 128, 256, 512, 1024):
        out = mac_icon(master, px)
        out.save(os.path.join(mac, f'app_icon_{px}.png'))

    # Windows: one .ico with the usual sizes.
    ico = os.path.join(APP, 'windows/runner/resources/app_icon.ico')
    master.save(ico, sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    print('icons written')


if __name__ == '__main__':
    main()
