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
      characters: self.characters?.components(separatedBy: ",").filter { !$0.isEmpty } ?? [],
      ageRange: BabyStage(rawValue: self.ageRange ?? "") ?? .toddler,
      readingTime: self.readingTime > 0 ? self.readingTime : nil,
      tags: self.tags?.components(separatedBy: ",").filter { !$0.isEmpty } ?? []
    )
  }
  
  func updateFromModel(_ story: Story) {
    self.id = story.id
    self.title = story.title
    self.content = story.content
    self.date = story.date
    self.isFavorite = story.isFavorite
    self.theme = story.theme
    self.length = story.length.rawValue
    self.characters = story.characters.joined(separator: ",")
    self.ageRange = story.ageRange.rawValue
    self.readingTime = story.readingTime ?? 0
    self.tags = story.tags.joined(separator: ",")
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
  // reading time in seconds
  @NSManaged public var readingTime: Double
  // tags
  @NSManaged public var tags: String?
  
}

extension StoryEntity: Identifiable {}
