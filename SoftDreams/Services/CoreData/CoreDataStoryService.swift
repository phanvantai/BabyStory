//
//  CoreDataStoryService.swift
//  SoftDreams
//
//  Created by Tai Phan Van on 2/6/25.
//

import Foundation
import CoreData

// MARK: - Core Data Story Service
/// Core Data implementation of StoryServiceProtocol
class CoreDataStoryService: StoryServiceProtocol {
  
  // MARK: - Properties
  private let context: NSManagedObjectContext
  
  // MARK: - Initialization
  init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
    self.context = context
  }
  
  // MARK: - StoryServiceProtocol Implementation
  
  func saveStories(_ stories: [Story]) throws {
    for story in stories {
      try saveStory(story)
    }
  }
  
  func loadStories() throws -> [Story] {
    let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
    do {
      let entities = try context.fetch(request)
      return entities.map { $0.toModel() }
    } catch {
      throw AppError.dataCorruption
    }
  }
  
  func saveStory(_ story: Story) throws {
    let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", story.id as CVarArg)
    
    do {
      let existingEntities = try context.fetch(request)
      let entity: StoryEntity
      
      if let existingEntity = existingEntities.first {
        entity = existingEntity
      } else {
        entity = StoryEntity(context: context)
      }
      
      entity.updateFromModel(story)
      
      try CoreDataStack.shared.save()
    } catch {
      throw AppError.storySaveFailed
    }
  }
  
  func deleteStory(withId id: String) throws {
    guard let uuid = UUID(uuidString: id) else {
      throw AppError.invalidData
    }
    
    let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    
    do {
      let entities = try context.fetch(request)
      for entity in entities {
        context.delete(entity)
      }
      
      try CoreDataStack.shared.save()
    } catch {
      throw AppError.storySaveFailed
    }
  }
  
  func updateStory(_ story: Story) throws {
    try saveStory(story) // This handles both insert and update
  }
  
  func getStory(withId id: String) throws -> Story? {
    guard let uuid = UUID(uuidString: id) else {
      return nil
    }
    
    let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    request.fetchLimit = 1
    
    do {
      let entities = try context.fetch(request)
      return entities.first?.toModel()
    } catch {
      throw AppError.dataCorruption
    }
  }
  
  func searchStories(containing searchTerm: String) throws -> [Story] {
    let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
    request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", searchTerm, searchTerm)
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
    do {
      let entities = try context.fetch(request)
      return entities.map { $0.toModel() }
    } catch {
      throw AppError.dataCorruption
    }
  }
  
  func getStoryCount() throws -> Int {
    let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
    
    do {
      return try context.count(for: request)
    } catch {
      throw AppError.dataCorruption
    }
  }
}

// MARK: - Additional Methods for Tests
extension CoreDataStoryService {
  
  /// Fetch all stories - async version for tests
  func fetchAllStories() async throws -> [Story] {
    return try await withCheckedThrowingContinuation { continuation in
      context.perform {
        do {
          let stories = try self.loadStories()
          continuation.resume(returning: stories)
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Save story - async version for tests
  func saveStory(_ story: Story) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      context.perform {
        do {
          try self.saveStory(story)
          continuation.resume()
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Delete story - async version for tests
  func deleteStory(withId id: String) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      context.perform {
        do {
          try self.deleteStory(withId: id)
          continuation.resume()
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Toggle favorite status
  func toggleFavorite(storyId: String) async throws {
    guard let uuid = UUID(uuidString: storyId) else {
      throw AppError.invalidData
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      context.perform {
        do {
          let request: NSFetchRequest<StoryEntity> = StoryEntity.fetchRequest()
          request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
          request.fetchLimit = 1
          
          let entities = try self.context.fetch(request)
          guard let entity = entities.first else {
            continuation.resume(throwing: AppError.invalidData)
            return
          }
          
          entity.isFavorite.toggle()
          try CoreDataStack.shared.save()
          continuation.resume()
        } catch {
          continuation.resume(throwing: AppError.storySaveFailed)
        }
      }
    }
  }
}
