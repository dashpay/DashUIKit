# Utilities

Small layout helpers in `Components/Geometry/`. They carry no DS styling — they're
mechanics for measuring and fitting views.

---

## Frame reader

File `Components/Geometry/FrameReader.swift`

Reads a view's frame in a coordinate space via a background `GeometryReader`, without
disturbing layout. The callback fires on appear and on change.

```swift
MyView()
    .readingFrame(coordinateSpace: .global) { frame in
        // frame: CGRect
    }
```

---

## ScrollViewWithOnScrollChanged

File `Components/Geometry/ScrollViewWithOnScrollChanged.swift`

A `ScrollView` that reports its content's scroll origin as it moves — handy for
scroll-driven effects (collapsing headers, shadows, parallax). Built on
`onScrollGeometryChange`.

```swift
ScrollViewWithOnScrollChanged(.vertical, showsIndicators: false) {
    VStack { /* content */ }
} onScrollChanged: { origin in
    // origin: CGPoint — .zero at rest, negative as the content scrolls towards its end,
    // positive while it is pulled past the start (rubber-banding)
}
```

- The origin is measured inside every content inset — safe area, `safeAreaPadding` and
  `contentMargins` alike — so it reads `.zero` at rest whatever insets the host adds.
- `x` follows the layout direction: in right-to-left layouts, scrolling towards the end is
  negative too.
- Only this scroll view's own offset is reported; a scroll view nested in the content does not
  feed it.
- The last value is sent again when the content appears again with its state kept (switching
  back to its tab, for example).
- The content starts one default stack spacing below the top.

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
