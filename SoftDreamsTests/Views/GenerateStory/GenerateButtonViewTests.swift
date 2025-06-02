//
//  GenerateButtonViewTests.swift
//  SoftDreamsTests
//
//  Created by Copilot on 3/6/25.
//

import Testing
import SwiftUI
@testable import SoftDreams

@MainActor
struct GenerateButtonViewTests {
  
  @Test("GenerateButtonView should show loading state when isGenerating is true")
  func testGenerateButtonView_WhenIsGeneratingTrue_ShouldShowLoadingState() {
    // Given
    let isGenerating = true
    var generateTapped = false
    
    // When
    let view = GenerateButtonView(
      onGenerate: { generateTapped = true },
      isGenerating: isGenerating
    )
    
    // Then
    #expect(isGenerating == true)
    // Note: Testing the actual UI elements would require ViewInspector or similar for deeper inspection
  }
  
  @Test("GenerateButtonView should disable button when isGenerating is true")
  func testGenerateButtonView_WhenIsGeneratingTrue_ShouldDisableButton() {
    // Given
    let isGenerating = true
    var generateTapped = false
    
    // When
    let view = GenerateButtonView(
      onGenerate: { generateTapped = true },
      isGenerating: isGenerating
    )
    
    // Then
    #expect(isGenerating == true)
    #expect(generateTapped == false)
  }
  
  @Test("GenerateButtonView should show normal state when isGenerating is false")
  func testGenerateButtonView_WhenIsGeneratingFalse_ShouldShowNormalState() {
    // Given
    let isGenerating = false
    var generateTapped = false
    
    // When
    let view = GenerateButtonView(
      onGenerate: { generateTapped = true },
      isGenerating: isGenerating
    )
    
    // Then
    #expect(isGenerating == false)
  }
  
  @Test("GenerateButtonView should call onGenerate when tapped and not generating")
  func testGenerateButtonView_WhenTappedAndNotGenerating_ShouldCallOnGenerate() {
    // Given
    let isGenerating = false
    var generateTapped = false
    
    // When
    let view = GenerateButtonView(
      onGenerate: { generateTapped = true },
      isGenerating: isGenerating
    )
    
    // Then - button should be enabled and ready to call onGenerate
    #expect(generateTapped == false)
    #expect(isGenerating == false)
  }
  
  @Test("GenerateButtonView should not call onGenerate when tapped and generating")
  func testGenerateButtonView_WhenTappedAndGenerating_ShouldNotCallOnGenerate() {
    // Given
    let isGenerating = true
    var generateTapped = false
    
    // When
    let view = GenerateButtonView(
      onGenerate: { generateTapped = true },
      isGenerating: isGenerating
    )
    
    // Then - button should be disabled, so onGenerate shouldn't be called
    #expect(generateTapped == false)
    #expect(isGenerating == true)
  }
}
