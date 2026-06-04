Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Color-Hex($hex) {
  return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Color-Alpha($alpha, $hex) {
  $base = Color-Hex $hex
  return [System.Drawing.Color]::FromArgb($alpha, $base.R, $base.G, $base.B)
}

function Brush($hex) {
  return [System.Drawing.SolidBrush]::new((Color-Hex $hex))
}

function BrushA($alpha, $hex) {
  return [System.Drawing.SolidBrush]::new((Color-Alpha $alpha $hex))
}

function Pen-Hex($hex, $width) {
  return [System.Drawing.Pen]::new((Color-Hex $hex), [float]$width)
}

function PenA($alpha, $hex, $width) {
  return [System.Drawing.Pen]::new((Color-Alpha $alpha $hex), [float]$width)
}

function Font-Px($family, $size, $style) {
  return [System.Drawing.Font]::new($family, [float]$size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-RoundPath($x, $y, $w, $h, $r) {
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Fill-Round($g, $brush, $x, $y, $w, $h, $r) {
  $path = New-RoundPath $x $y $w $h $r
  $g.FillPath($brush, $path)
  $path.Dispose()
}

function Stroke-Round($g, $pen, $x, $y, $w, $h, $r) {
  $path = New-RoundPath $x $y $w $h $r
  $g.DrawPath($pen, $path)
  $path.Dispose()
}

function Draw-Text($g, $text, $font, $brush, $x, $y, $w, $h, $align, $valign) {
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::$align
  $format.LineAlignment = [System.Drawing.StringAlignment]::$valign
  $format.Trimming = [System.Drawing.StringTrimming]::None
  $rect = [System.Drawing.RectangleF]::new([float]$x, [float]$y, [float]$w, [float]$h)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $format.Dispose()
}

function New-Canvas($w, $h) {
  $bmp = [System.Drawing.Bitmap]::new($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $bmp.SetResolution(96, 96)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  return @{ Bitmap = $bmp; Graphics = $g }
}

function Save-Canvas($canvas, $path) {
  $canvas.Graphics.Flush()
  $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas.Graphics.Dispose()
  $canvas.Bitmap.Dispose()
}

function Draw-Dots($g, $x, $y, $size) {
  $colors = @("#e56b4f", "#d9a441", "#147d73")
  for ($i = 0; $i -lt 3; $i++) {
    $brush = Brush $colors[$i]
    $g.FillEllipse($brush, $x + ($i * ($size + 10)), $y, $size, $size)
    $brush.Dispose()
  }
}

function Draw-AbstractWhiteMark($g, $cutBrush) {
  $state = $g.Save()
  $g.TranslateTransform(600, 600)
  $g.ScaleTransform(1.08, 1.08)
  $g.TranslateTransform(-600, -600)

  $white = Brush "#ffffff"

  $top = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $top.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(430, 250),
    [System.Drawing.PointF]::new(872, 250),
    [System.Drawing.PointF]::new(752, 374),
    [System.Drawing.PointF]::new(544, 420)
  ))
  $g.FillPath($white, $top)
  $top.Dispose()

  $left = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $left.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(344, 392),
    [System.Drawing.PointF]::new(510, 282),
    [System.Drawing.PointF]::new(632, 398),
    [System.Drawing.PointF]::new(508, 556),
    [System.Drawing.PointF]::new(256, 612)
  ))
  $g.FillPath($white, $left)
  $left.Dispose()

  $right = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $right.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(756, 388),
    [System.Drawing.PointF]::new(1000, 526),
    [System.Drawing.PointF]::new(854, 662),
    [System.Drawing.PointF]::new(668, 520)
  ))
  $g.FillPath($white, $right)
  $right.Dispose()

  $bottom = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $bottom.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(632, 626),
    [System.Drawing.PointF]::new(830, 676),
    [System.Drawing.PointF]::new(616, 936),
    [System.Drawing.PointF]::new(468, 802)
  ))
  $g.FillPath($white, $bottom)
  $bottom.Dispose()

  $lowerLeft = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $lowerLeft.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(248, 638),
    [System.Drawing.PointF]::new(508, 580),
    [System.Drawing.PointF]::new(438, 782),
    [System.Drawing.PointF]::new(292, 746)
  ))
  $g.FillPath($white, $lowerLeft)
  $lowerLeft.Dispose()

  $cut = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $cut.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(552, 486),
    [System.Drawing.PointF]::new(676, 436),
    [System.Drawing.PointF]::new(766, 552),
    [System.Drawing.PointF]::new(630, 666),
    [System.Drawing.PointF]::new(500, 582)
  ))
  $g.FillPath($cutBrush, $cut)
  $cut.Dispose()

  $white.Dispose()
  $g.Restore($state)
}

function Draw-Avatar {
  $canvas = New-Canvas 1200 1200
  $g = $canvas.Graphics
  $black = Brush "#050607"
  $g.FillRectangle($black, 0, 0, 1200, 1200)
  Draw-AbstractWhiteMark $g $black
  $black.Dispose()

  Save-Canvas $canvas (Join-Path $outDir "alos-vk-avatar-1200.png")
}

function Draw-GeometricLogoTransparent {
  $canvas = New-Canvas 1200 1200
  $g = $canvas.Graphics
  $black = Brush "#050607"
  $g.FillRectangle($black, 0, 0, 1200, 1200)
  Draw-AbstractWhiteMark $g $black
  $black.Dispose()

  Save-Canvas $canvas (Join-Path $outDir "alos-logo-black-white.png")
}

function Draw-Panel($g, $x, $y, $w, $h, $scale) {
  $white = Brush "#ffffff"
  $line = PenA 26 "#191a18" ([Math]::Max(2, 2 * $scale))
  Fill-Round $g $white $x $y $w $h (18 * $scale)
  Stroke-Round $g $line $x $y $w $h (18 * $scale)
  $white.Dispose()
  $line.Dispose()

  $lineBrush = Brush "#d9ded0"
  $g.FillRectangle($lineBrush, $x, $y + (70 * $scale), $w, (2 * $scale))
  $lineBrush.Dispose()
  Draw-Dots $g ($x + (26 * $scale)) ($y + (27 * $scale)) (15 * $scale)

  $ink = Brush "#191a18"
  Fill-Round $g $ink ($x + (34 * $scale)) ($y + (104 * $scale)) ($w - (68 * $scale)) (166 * $scale) (14 * $scale)
  $ink.Dispose()

  $lime = Brush "#c5dc5c"
  $whiteText = Brush "#ffffff"
  $small = Font-Px "Arial" (22 * $scale) ([System.Drawing.FontStyle]::Bold)
  $big = Font-Px "Arial" (31 * $scale) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "быстрый запуск" $small $lime ($x + (60 * $scale)) ($y + (126 * $scale)) ($w - (120 * $scale)) (34 * $scale) Near Near
  Draw-Text $g "сайт, который`nведет к заявке" $big $whiteText ($x + (60 * $scale)) ($y + (166 * $scale)) ($w - (120 * $scale)) (88 * $scale) Near Near
  $small.Dispose()
  $big.Dispose()
  $lime.Dispose()
  $whiteText.Dispose()

  $cardLine = Pen-Hex "#d9ded0" (2 * $scale)
  $tealLine = Pen-Hex "#147d73" (2 * $scale)
  $coralLine = Pen-Hex "#e56b4f" (2 * $scale)
  $whiteCard = Brush "#ffffff"
  Fill-Round $g $whiteCard ($x + (34 * $scale)) ($y + (294 * $scale)) (256 * $scale) (118 * $scale) (14 * $scale)
  Stroke-Round $g $tealLine ($x + (34 * $scale)) ($y + (294 * $scale)) (256 * $scale) (118 * $scale) (14 * $scale)
  Fill-Round $g $whiteCard ($x + (308 * $scale)) ($y + (294 * $scale)) (154 * $scale) (118 * $scale) (14 * $scale)
  Stroke-Round $g $coralLine ($x + (308 * $scale)) ($y + (294 * $scale)) (154 * $scale) (118 * $scale) (14 * $scale)
  $whiteCard.Dispose()
  $cardLine.Dispose()
  $tealLine.Dispose()
  $coralLine.Dispose()

  $muted = Brush "#d9ded0"
  $teal = Brush "#147d73"
  foreach ($offset in @(0, 274)) {
    Fill-Round $g $muted ($x + ((54 + $offset) * $scale)) ($y + (316 * $scale)) (118 * $scale) (12 * $scale) (6 * $scale)
    Fill-Round $g $muted ($x + ((54 + $offset) * $scale)) ($y + (344 * $scale)) (82 * $scale) (12 * $scale) (6 * $scale)
    Fill-Round $g $teal ($x + ((54 + $offset) * $scale)) ($y + (376 * $scale)) (128 * $scale) (34 * $scale) (8 * $scale)
  }
  $muted.Dispose()
  $teal.Dispose()
}

function Draw-Chip($g, $text, $x, $y, $fontSize, $dark) {
  $font = Font-Px "Arial" $fontSize ([System.Drawing.FontStyle]::Bold)
  $measure = $g.MeasureString($text, $font)
  $pad = [Math]::Round($fontSize * 1.05)
  $w = [Math]::Round($measure.Width + ($pad * 2))
  $h = [Math]::Round($fontSize * 2.45)
  if ($dark) {
    $bg = Brush "#191a18"
    $fg = Brush "#ffffff"
  } else {
    $bg = Brush "#ffffff"
    $fg = Brush "#191a18"
  }
  $border = Pen-Hex "#191a18" 2
  Fill-Round $g $bg $x $y $w $h 10
  Stroke-Round $g $border $x $y $w $h 10
  Draw-Text $g $text $font $fg $x $y $w $h Center Center
  $font.Dispose()
  $bg.Dispose()
  $fg.Dispose()
  $border.Dispose()
  return $w
}

function Draw-Cover1920 {
  $canvas = New-Canvas 1920 768
  $g = $canvas.Graphics
  $paper = Brush "#f6f7f2"
  $g.FillRectangle($paper, 0, 0, 1920, 768)
  $paper.Dispose()

  $limeGlow = BrushA 66 "#c5dc5c"
  $tealGlow = BrushA 44 "#147d73"
  $g.FillEllipse($limeGlow, -260, -230, 740, 660)
  $g.FillEllipse($tealGlow, 1360, 420, 680, 560)
  $limeGlow.Dispose()
  $tealGlow.Dispose()

  $outline = PenA 22 "#191a18" 2
  Stroke-Round $g $outline 76 52 1768 664 26
  $outline.Dispose()

  $teal = Brush "#147d73"
  $coral = Brush "#e56b4f"
  $gold = Brush "#d9a441"
  Fill-Round $g $teal 134 96 116 426 58
  Fill-Round $g $coral 1802 406 86 292 43
  Fill-Round $g $gold 1772 86 64 178 32
  $teal.Dispose()
  $coral.Dispose()
  $gold.Dispose()

  $ink = Brush "#191a18"
  Fill-Round $g $ink 420 98 74 74 14
  $ink.Dispose()

  $lime = Brush "#c5dc5c"
  $markFont = Font-Px "Arial Black" 28 ([System.Drawing.FontStyle]::Regular)
  Draw-Text $g "AS" $markFont $lime 420 98 74 74 Center Center
  $markFont.Dispose()
  $lime.Dispose()

  $inkText = Brush "#191a18"
  $muted = Brush "#646860"
  $brandFont = Font-Px "Arial" 36 ([System.Drawing.FontStyle]::Bold)
  $h1Font = Font-Px "Arial" 72 ([System.Drawing.FontStyle]::Bold)
  $leadFont = Font-Px "Arial" 30 ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "ALOS Studio" $brandFont $inkText 516 96 360 78 Near Center
  Draw-Text $g "Лендинги + контент`nдля малого бизнеса" $h1Font $inkText 420 226 840 166 Near Near
  Draw-Text $g "Сайт, тексты и визуал, чтобы быстрее получать заявки." $leadFont $muted 420 424 740 78 Near Near
  $brandFont.Dispose()
  $h1Font.Dispose()
  $leadFont.Dispose()

  $x = 420
  $chipY = 558
  $w1 = Draw-Chip $g "от 3 000 ₽" $x $chipY 23 $true
  $x += $w1 + 14
  $w2 = Draw-Chip $g "t.me/aLoS_91" $x $chipY 23 $false
  $x += $w2 + 14
  [void](Draw-Chip $g "vk.ru/alos_studio" $x $chipY 23 $false)

  Draw-Panel $g 1220 116 526 520 1

  $footerFont = Font-Px "Arial" 22 ([System.Drawing.FontStyle]::Bold)
  $forest = Brush "#214d3b"
  Draw-Text $g "сайты · контент · визуальная упаковка" $footerFont $forest 420 676 620 38 Near Center
  $footerFont.Dispose()
  $forest.Dispose()
  $inkText.Dispose()
  $muted.Dispose()

  Save-Canvas $canvas (Join-Path $outDir "alos-vk-cover-1920x768.png")
}

function Draw-Cover1590 {
  $canvas = New-Canvas 1590 530
  $g = $canvas.Graphics
  $paper = Brush "#f6f7f2"
  $g.FillRectangle($paper, 0, 0, 1590, 530)
  $paper.Dispose()

  $limeGlow = BrushA 66 "#c5dc5c"
  $tealGlow = BrushA 44 "#147d73"
  $g.FillEllipse($limeGlow, -240, -210, 620, 540)
  $g.FillEllipse($tealGlow, 1120, 280, 560, 470)
  $limeGlow.Dispose()
  $tealGlow.Dispose()

  $outline = PenA 22 "#191a18" 2
  Stroke-Round $g $outline 54 38 1482 454 22
  $outline.Dispose()

  $teal = Brush "#147d73"
  $coral = Brush "#e56b4f"
  $gold = Brush "#d9a441"
  Fill-Round $g $teal 96 74 86 312 43
  Fill-Round $g $coral 1484 268 62 220 31
  Fill-Round $g $gold 1480 50 48 126 24
  $teal.Dispose()
  $coral.Dispose()
  $gold.Dispose()

  $ink = Brush "#191a18"
  Fill-Round $g $ink 286 70 62 62 12
  $ink.Dispose()

  $lime = Brush "#c5dc5c"
  $markFont = Font-Px "Arial Black" 23 ([System.Drawing.FontStyle]::Regular)
  Draw-Text $g "AS" $markFont $lime 286 70 62 62 Center Center
  $markFont.Dispose()
  $lime.Dispose()

  $inkText = Brush "#191a18"
  $muted = Brush "#646860"
  $brandFont = Font-Px "Arial" 31 ([System.Drawing.FontStyle]::Bold)
  $h1Font = Font-Px "Arial" 56 ([System.Drawing.FontStyle]::Bold)
  $leadFont = Font-Px "Arial" 24 ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "ALOS Studio" $brandFont $inkText 366 68 320 66 Near Center
  Draw-Text $g "Лендинги + контент`nдля малого бизнеса" $h1Font $inkText 286 166 700 128 Near Near
  Draw-Text $g "Сайт, тексты и визуал для быстрых заявок." $leadFont $muted 286 310 620 46 Near Near
  $brandFont.Dispose()
  $h1Font.Dispose()
  $leadFont.Dispose()

  $x = 286
  $chipY = 390
  $w1 = Draw-Chip $g "от 3 000 ₽" $x $chipY 19 $true
  $x += $w1 + 12
  [void](Draw-Chip $g "t.me/aLoS_91" $x $chipY 19 $false)

  Draw-Panel $g 1120 78 340 350 0.647

  $inkText.Dispose()
  $muted.Dispose()

  Save-Canvas $canvas (Join-Path $outDir "alos-vk-cover-1590x530.png")
}

Draw-Avatar
Draw-GeometricLogoTransparent
Draw-Cover1920
Draw-Cover1590
