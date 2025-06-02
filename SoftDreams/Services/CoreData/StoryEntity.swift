//
//  StoryEntity.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 2/6/25.
//

import Foundation
import CoreData

@objc(StoryEntity)
public class StoryEntity: NSManagedObject {
  func toModel() -> Story {
    return Story(
      id: self.id ?? UUID(),
      title: title ?? "",
      content: self.content ?? "",
      date: self.date ?? Date(),
      isFavorite: self.isFavorite,
      theme: self.theme ?? "",
      length: StoryLength(rawValue: self.length ?? "") ?? .medium,
      characters: self.characters?.components(separatedBy: ",") ?? [],
      ageRange: BabyStage(rawValue: self.ageRange ?? "") ?? .toddler,
      tags: self.tags?.components(separatedBy: ",") ?? []
    )
  }
}

extension StoryEntity {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryEntity> {
    return NSFetchRequest<StoryEntity>(entityName: "StoryEntity")
  }
  
  @NSManaged public var id: UUID?
  @NSManaged public var title: String?
  @NSManaged public var content: String?
  // date
  @NSManaged public var date: Date?
  // is favorite
  @NSManaged public var isFavorite: Bool
  
  @NSManaged public var theme: String?
  @NSManaged public var length: String?
  @NSManaged public var characters: String?
  // age range
  @NSManaged public var ageRange: String?
  // tags
  @NSManaged public var tags: String?
  
}

extension StoryEntity: Identifiable {}
