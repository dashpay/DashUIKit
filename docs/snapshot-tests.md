# Snapshot tests

Snapshot tests render components and compare them, pixel by pixel, with reference images
committed in the repo, in light and in dark mode. They catch a change nobody meant to make,
such as a token edit that moves another component.

## Where they are

```text
SnapshotTests/                       its own package; the library's Package.swift is untouched
  Package.swift                      path dependency on "..", swift-snapshot-testing (exact pin)
  Package.resolved                   committed: the versions CI starts from
  Tests/DashUIKitSnapshotTests/
    SnapshotSupport.swift            assertComponentSnapshots, ReferenceEnvironment
    <Component>SnapshotTests.swift   one file per component, public API only
    __Snapshots__/<File>/<test>.<name>-light.png / -dark.png
```

The tests live in a separate package so that the snapshot library never appears in the
manifest that apps resolve. `swift build` and `xcodebuild -scheme DashUIKit` at the repo
root do not see them.

Each test calls `assertComponentSnapshots(of:named:background:)`. It renders the view
402 pt wide (iPhone 17 / 17 Pro) at 3×, with 16 pt of padding, on `Color.dash.primaryBackground`
unless a background is given. A test fails when any pixel differs by more than a colour
distance (ΔE) of 2. That absorbs anti-aliasing noise. A moved edge fails; a colour token
change fails when it moves a colour by more than ΔE 2, about the smallest difference the eye
sees.

Covered: `DashButton` (every style and size, enabled and disabled, icons, full width),
`MenuItem`, `Toast` (every style but `.loading`, whose spinner animates on a timer), `SwitchView`, `NavigationBar`, `BottomSheet` and `SheetFeature`,
`SearchBar`, `TransactionView`. There is no Dynamic Type snapshot: the type tokens are fixed
sizes (`Font.system(size:)`), so a larger content size renders the same pixels.

Without a host app the images are drawn from the layer tree, so a `UIVisualEffectView` (the
blur behind `Toast`) is not in them; a change to it does not fail a test.

## The references come from CI

Text, SF Symbols and SwiftUI layout render differently on each iOS release, so a reference
rendered on one simulator does not match another one. The references are therefore rendered
by the `Snapshot tests (iOS Simulator)` CI job (the Xcode in `.github/actions/select-xcode`,
the simulator `pick-simulator.sh` picks for it), and compared only on that environment. The
Xcode version fixes the SDK, and so the runtime and device types the picker can choose:

- `ReferenceEnvironment` in `SnapshotSupport.swift` names it: the simulator runtime's
  version and build, the simulator model, the text direction, and how the locale writes 1234.5 (amounts use `Locale.current`; the
  job runs with `-testLanguage en -testRegion US`).
- **Anywhere else** every snapshot test is **skipped**, with a message naming both
  environments. Locally on a newer Xcode, `xcodebuild test` reports them as skipped, not
  passed.
- **On CI** a different environment **fails** the job
  (`SNAPSHOT_REQUIRE_REFERENCE_ENVIRONMENT=1`), so a runner image update cannot turn the
  suite into skips.
- `SNAPSHOT_FORCE=1` compares anyway, for example on a local simulator with the same iOS
  version.

## Recording and updating references

Changed a component on purpose, or added a test? CI records the new images for you:

1. Push the branch, with a PR open (CI runs on pull requests and on `master`). The snapshot job renders the PR head (not its merge with `master`, so
   the images show the branch's own code). It fails on every missing or changed reference,
   writes the new image in its place and uploads the whole `__Snapshots__` folder as the
   artifact `snapshots`.
2. When the run has finished, from the repo root, on the same commit:

   ```sh
   .github/scripts/fetch-snapshots.sh            # newest CI run of HEAD
   .github/scripts/fetch-snapshots.sh <run-id>   # or a given run
   ```

   It replaces `SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__` with the artifact
   and lists the changed files.
3. Look at the changed images (open them, or compare with `git difftool`). If the change is
   the one you meant, commit and push; the next run passes, and the PR's file view shows
   each image before and after. If it is not, the images still show what CI rendered:
   discard them and fix the code:

   ```sh
   git clean -fd -- SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__
   git checkout -- SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__   # when some are committed
   ```

The job renders the branch, not its merge with `master`. After `master` changed a component
your branch also renders, merge `master`, push, and run step 2 again before merging; else
the snapshot job fails on `master` after the merge, and the fix is a follow-up PR that
fetches that run's references. Delete the references of a removed test by hand.

Run locally, Xcode also shows the reference, the new image and a difference image as
attachments of a failing test. CI does not keep its result bundle; the artifact is the way
to see what it rendered.

### Running locally

```sh
cd SnapshotTests
xcodebuild test -scheme DashUIKitSnapshotTests-Package \
  -destination "platform=iOS Simulator,name=<iPhone>" \
  -testLanguage en -testRegion US
```

Environment variables reach the tests with the `TEST_RUNNER_` prefix:
`TEST_RUNNER_SNAPSHOT_FORCE=1` compares on another environment;
`TEST_RUNNER_SNAPSHOT_TESTING_RECORD=all` rewrites every reference (off the reference
environment, together with `TEST_RUNNER_SNAPSHOT_FORCE=1`, or the tests skip first). Images recorded on
another environment are only good for trying things out; do not commit them.

### Moving CI to a new Xcode

When `select-xcode` (or the runner image) moves to a new iOS runtime or runtime build, the
job fails with the environment message. Update every value of `ReferenceEnvironment` it
names (runtime, model, number format), push, and
fetch the re-recorded set as above.

### Bumping swift-snapshot-testing

The pin is `exact:` in `SnapshotTests/Package.swift`. Pick a release at least two weeks old,
run `swift package update` in `SnapshotTests/`, commit both files, and check that the job
still passes (a change in rendering or comparison shows up as a failure; re-record if it is
expected).
