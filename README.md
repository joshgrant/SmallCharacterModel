# Small Character Model

## Example:
```
var smallCharacterModel = SmallCharacterModel.State(source: .preTrainedBundleModel(.init(
            name: "song-titles",
            cohesion: 3,
            fileExtension: "media")))

...

.smallCharacterModel(.wordGenerator(.generate(prefix: "", length: 5))))
```

## Usage

I regret using TCA just because it's architecturally heavy for such a simple program. Otherwise, trains a model based on a data set, or generates words based on the model.
