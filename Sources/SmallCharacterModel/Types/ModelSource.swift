import Foundation

public enum ModelSource: Equatable {
    case preTrainedBundleModel(PreTrainedBundleModelSource)
    case trainingData(TrainingDataSource)
}
