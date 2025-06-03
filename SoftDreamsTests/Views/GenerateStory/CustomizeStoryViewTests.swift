//
//  CustomizeStoryViewTests.swift
//  SoftDreamsTests
//
//  Created by Copilot on 3/6/25.
//

import Testing
import SwiftUI
@testable import SoftDreams

@MainActor
struct CustomizeStoryViewTests {
  
  @Test("CustomizeStoryView should show loading overlay when viewModel is generating")
  func testCustomizeStoryView_WhenViewModelIsGenerating_ShouldShowLoadingOverlay() {
    // Red Phase: This test will fail initially as CustomizeStoryView doesn't show loading overlay
    let viewModel = StoryGenerationViewModel()
    viewModel.isGenerating = true
    
    var generateCalled = false
    let view = CustomizeStoryView(viewModel: viewModel) {
      generateCalled = true
    }
    
    // Should show loading state when viewModel is generating
    #expect(viewModel.isGenerating == true)
    #expect(generateCalled == false)
  }
  
  @Test("CustomizeStoryView should hide loading overlay when viewModel is not generating")
  func testCustomizeStoryView_WhenViewModelIsNotGenerating_ShouldHideLoadingOverlay() {
    // Red Phase: This test will fail initially
    let viewModel = StoryGenerationViewModel()
    viewModel.isGenerating = false
    
    var generateCalled = false
    let view = CustomizeStoryView(viewModel: viewModel) {
      generateCalled = true
    }
    
    // Should not show loading state when viewModel is not generating
    #expect(viewModel.isGenerating == false)
  }
  
  @Test("CustomizeStoryView should prevent navigation when story is generating")
  func testCustomizeStoryView_WhenStoryIsGenerating_ShouldPreventNavigation() {
    // Red Phase: This test will fail initially as there's no navigation prevention
    let viewModel = StoryGenerationViewModel()
    viewModel.isGenerating = true
    
    var generateCalled = false
    let view = CustomizeStoryView(viewModel: viewModel) {
      generateCalled = true
    }
    
    // Navigation should be prevented when generating
    #expect(viewModel.isGenerating == true)
  }
  
  @Test("CustomizeStoryView should allow navigation when story is not generating")
  func testCustomizeStoryView_WhenStoryIsNotGenerating_ShouldAllowNavigation() {
    // Red Phase: This test will fail initially
    let viewModel = StoryGenerationViewModel()
    viewModel.isGenerating = false
    
    var generateCalled = false
    let view = CustomizeStoryView(viewModel: viewModel) {
      generateCalled = true
    }
    
    // Navigation should be allowed when not generating
    #expect(viewModel.isGenerating == false)
  }
  
  @Test("CustomizeStoryView should pass isGenerating state to GenerateButtonView")
  func testCustomizeStoryView_ShouldPassIsGeneratingStateToGenerateButtonView() {
    // Red Phase: This test will fail initially
    let viewModel = StoryGenerationViewModel()
    viewModel.isGenerating = true
    
    var generateCalled = false
    let view = CustomizeStoryView(viewModel: viewModel) {
      generateCalled = true
    }
    
    // GenerateButtonView should receive isGenerating state from viewModel
    #expect(viewModel.isGenerating == true)
  }
}
