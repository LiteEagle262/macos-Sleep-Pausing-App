import AppKit

let directory = CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let image = NSImage(size: NSSize(width: pixels, height: pixels))
        image.lockFocus()
        let p = CGFloat(pixels)
        NSColor(calibratedRed: 0.12, green: 0.17, blue: 0.25, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: p * 0.06, y: p * 0.06, width: p * 0.88, height: p * 0.88), xRadius: p * 0.2, yRadius: p * 0.2).fill()
        NSColor(calibratedRed: 0.85, green: 0.91, blue: 1, alpha: 1).setStroke()
        let ring = NSBezierPath(ovalIn: NSRect(x: p * 0.23, y: p * 0.23, width: p * 0.54, height: p * 0.54))
        ring.lineWidth = p * 0.045
        ring.stroke()
        NSColor(calibratedRed: 0.85, green: 0.91, blue: 1, alpha: 1).setFill()
        for x in [0.39, 0.54] {
            NSBezierPath(roundedRect: NSRect(x: p * x, y: p * 0.36, width: p * 0.07, height: p * 0.28), xRadius: p * 0.025, yRadius: p * 0.025).fill()
        }
        image.unlockFocus()
        let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
        let suffix = scale == 2 ? "@2x" : ""
        try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(directory)/icon_\(size)x\(size)\(suffix).png"))
    }
}
