# Utilities

Small layout helpers in `Components/Geometry/`. They carry no DS styling — they're
mechanics for measuring and fitting views.

---

## Frame & location readers

Files `Components/Geometry/FrameReader.swift`, `LocationReader.swift`

Read a view's frame or center point in a coordinate space via a background `GeometryReader`,
without disturbing layout. Callbacks fire on appear and on change.

```swift
// Public: read the full frame.
MyView()
    .readingFrame(coordinateSpace: .global) { frame in
        // frame: CGRect
    }

// Read just the center point (internal helper used by ScrollViewWithOnScrollChanged).
MyView()
    .readingLocation { center in
        // center: CGPoint
    }
```

`readingFrame` is public; `LocationReader` / `readingLocation` are internal building blocks.

---

## ScrollViewWithOnScrollChanged

File `Components/Geometry/ScrollViewWithOnScrollChanged.swift`

A `ScrollView` that reports its content's scroll origin as it moves — handy for
scroll-driven effects (collapsing headers, shadows, parallax). It works by placing a
`LocationReader` at the top of the content in a named coordinate space, which predates
`onScrollGeometryChange`; new code can use the system API directly.

```swift
ScrollViewWithOnScrollChanged(.vertical, showsIndicators: false) {
    VStack { /* content */ }
} onScrollChanged: { origin in
    // origin: CGPoint — content offset within the scroll view
}
```

---

## scaleToFitWidth

File `Components/Geometry/ScaleToFitWidth.swift`

Scales a view **uniformly** to fit the available width on a single line, shrinking the
whole group together (e.g. currency symbol + amount + logo) — unlike `minimumScaleFactor`,
which shrinks each `Text` independently. Renders at full size when it fits and never goes
below `minScale`. It reserves the content's natural single-line height so surrounding
vertical layout stays stable.

```swift
HStack { Text(symbol); Text(amount); dashLogo }
    .scaleToFitWidth(minScale: 0.35)   // default minScale 0.35
```

This is what keeps long amounts on one line in `SwapAmountView`.
