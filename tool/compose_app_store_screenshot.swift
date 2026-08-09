import AppKit

guard CommandLine.arguments.count == 9 else {
  fputs("usage: compose background screenshot logo output width height title subtitle\n", stderr)
  exit(2)
}

let backgroundPath = CommandLine.arguments[1]
let screenshotPath = CommandLine.arguments[2]
let logoPath = CommandLine.arguments[3]
let outputPath = CommandLine.arguments[4]
let width = Int(CommandLine.arguments[5])!
let height = Int(CommandLine.arguments[6])!
let title = CommandLine.arguments[7]
let subtitle = CommandLine.arguments[8]

guard let background = NSImage(contentsOfFile: backgroundPath),
      let screenshot = NSImage(contentsOfFile: screenshotPath),
      let logo = NSImage(contentsOfFile: logoPath) else {
  fputs("unable to load input image\n", stderr)
  exit(3)
}

let rep = NSBitmapImageRep(
  bitmapDataPlanes: nil,
  pixelsWide: width,
  pixelsHigh: height,
  bitsPerSample: 8,
  samplesPerPixel: 4,
  hasAlpha: true,
  isPlanar: false,
  colorSpaceName: .deviceRGB,
  bytesPerRow: 0,
  bitsPerPixel: 0
)!
let context = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

background.draw(
  in: NSRect(x: 0, y: 0, width: width, height: height),
  from: .zero,
  operation: .copy,
  fraction: 1
)

let logoSize = width < 1500 ? 108.0 : 132.0
logo.draw(
  in: NSRect(
    x: Double(width) / 2 - logoSize / 2,
    y: Double(height) - 165 - logoSize,
    width: logoSize,
    height: logoSize
  ),
  from: .zero,
  operation: .sourceOver,
  fraction: 1
)

let titleFontSize = width < 1500 ? 64.0 : 78.0
let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
let titleAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: titleFontSize, weight: .bold),
  .foregroundColor: NSColor.white,
  .paragraphStyle: paragraph,
]
(title as NSString).draw(
  in: NSRect(
    x: 70,
    y: Double(height) - 420,
    width: Double(width) - 140,
    height: 100
  ),
  withAttributes: titleAttributes
)

let subtitleAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: width < 1500 ? 34 : 42, weight: .medium),
  .foregroundColor: NSColor(calibratedWhite: 1, alpha: 0.82),
  .paragraphStyle: paragraph,
]
(subtitle as NSString).draw(
  in: NSRect(
    x: 75,
    y: Double(height) - 500,
    width: Double(width) - 150,
    height: 70
  ),
  withAttributes: subtitleAttributes
)

let screenWidth = width < 1500 ? 880.0 : 920.0
let screenHeight = screenWidth * Double(screenshot.size.height / screenshot.size.width)
let screenRect = NSRect(
  x: Double(width) / 2 - screenWidth / 2,
  y: 78,
  width: screenWidth,
  height: min(screenHeight, Double(height) - 620)
)

let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.5)
shadow.shadowBlurRadius = 34
shadow.shadowOffset = NSSize(width: 0, height: -10)
shadow.set()

let clip = NSBezierPath(roundedRect: screenRect, xRadius: 42, yRadius: 42)
clip.addClip()
screenshot.draw(in: screenRect, from: .zero, operation: .sourceOver, fraction: 1)

NSGraphicsContext.restoreGraphicsState()
guard let data = rep.representation(
  using: .jpeg,
  properties: [.compressionFactor: 0.96]
) else {
  exit(4)
}
try data.write(to: URL(fileURLWithPath: outputPath))
