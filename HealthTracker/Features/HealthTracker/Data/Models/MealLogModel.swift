import Foundation
import SwiftData

// MARK: - MealLogModel

@Model
final class MealLogModel {

    var id: UUID
    var mealSlotRaw: String        // MealSlot.rawValue
    var amount: Double?
    var freeText: String?

    // Stored as JPEG compressed data (quality 0.7)
    @Attribute(.externalStorage)
    var photoData: Data?

    var food: FoodModel?
    var report: DailyReportModel?

    init(
        id: UUID = UUID(),
        mealSlotRaw: String,
        amount: Double? = nil,
        freeText: String? = nil,
        photoData: Data? = nil,
        food: FoodModel? = nil,
        report: DailyReportModel? = nil
    ) {
        self.id = id
        self.mealSlotRaw = mealSlotRaw
        self.amount = amount
        self.freeText = freeText
        self.photoData = photoData
        self.food = food
        self.report = report
    }
}
