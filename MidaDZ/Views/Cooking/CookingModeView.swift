import SwiftUI
import UIKit

struct CookingModeView: View {
    let recipe: Recipe
    let servings: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var stepIndex = 0
    @State private var showIngredients = false
    @State private var completed = false
    @State private var keepAwake = true

    var body: some View {
        NavigationStack {
            ZStack {
                MidaColor.ink.ignoresSafeArea()
                if completed { completionView } else { stepView }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Exit") { dismiss() }.foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle("Keep screen awake", isOn: $keepAwake)
                        Button { showIngredients = true } label: { Label("View ingredients", systemImage: "list.bullet") }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(.white).font(.title3)
                    }
                    .accessibilityLabel("Cooking mode options")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showIngredients) { ingredientSheet }
            .onAppear { UIApplication.shared.isIdleTimerDisabled = keepAwake }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
            .onChange(of: keepAwake) { _, value in UIApplication.shared.isIdleTimerDisabled = value }
        }
        .preferredColorScheme(.dark)
    }

    private var stepView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name.uppercased()).font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(MidaColor.saffron)
                Text("Step \(stepIndex + 1) of \(recipe.instructions.count)").font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.62))
                ProgressView(value: Double(stepIndex + 1), total: Double(recipe.instructions.count)).tint(MidaColor.saffron)
            }
            .padding(.horizontal, MidaSpacing.lg)
            .padding(.top, MidaSpacing.xl)
            Spacer()
            VStack(alignment: .leading, spacing: MidaSpacing.lg) {
                Text(recipe.instructions[stepIndex])
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .id(stepIndex)
                if stepIndex == 0 {
                    Label("Ingredients are scaled for \(servings) servings", systemImage: "checklist")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
                }
            }
            .padding(.horizontal, MidaSpacing.lg)
            Spacer()
            HStack(spacing: MidaSpacing.sm) {
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) { stepIndex = max(0, stepIndex - 1) }
                } label: {
                    Image(systemName: "chevron.backward").frame(width: 54, height: 54).background(.white.opacity(0.12), in: Circle())
                }
                .disabled(stepIndex == 0)
                .opacity(stepIndex == 0 ? 0.35 : 1)
                .accessibilityLabel("Previous step")
                Spacer()
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) {
                        if stepIndex == recipe.instructions.count - 1 { completed = true } else { stepIndex += 1 }
                    }
                } label: {
                    HStack { Text(stepIndex == recipe.instructions.count - 1 ? "Finish" : "Next"); Image(systemName: stepIndex == recipe.instructions.count - 1 ? "checkmark" : "chevron.forward") }
                        .font(.headline.weight(.bold))
                        .padding(.horizontal, 22)
                        .frame(minHeight: 54)
                        .background(MidaColor.saffron, in: Capsule())
                }
                .accessibilityLabel(stepIndex == recipe.instructions.count - 1 ? "Finish cooking" : "Next step")
            }
            .foregroundStyle(.white)
            .padding(.horizontal, MidaSpacing.lg)
            .padding(.bottom, MidaSpacing.xl)
        }
    }

    private var completionView: some View {
        VStack(spacing: MidaSpacing.lg) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 78)).foregroundStyle(MidaColor.saffron)
            Text("Ready to serve").font(.system(size: 38, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text("You made \(recipe.name). Take a moment for the table, then save your notes for next time.").font(.body).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.7)).padding(.horizontal, MidaSpacing.xl)
            Button("Done") { dismiss() }
                .font(.headline.weight(.bold))
                .foregroundStyle(MidaColor.ink)
                .padding(.horizontal, 42)
                .frame(minHeight: 54)
                .background(MidaColor.saffron, in: Capsule())
        }
        .padding(MidaSpacing.lg)
    }

    private var ingredientSheet: some View {
        NavigationStack {
            List(recipe.ingredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.scaled(for: servings, baseServings: recipe.servings)).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ingredients")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showIngredients = false } } }
        }
        .presentationDetents([.medium, .large])
    }
}
