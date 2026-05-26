import Foundation

// MARK: - SystemPrompts
// Builds the clinical-sports system prompt dynamically from the user's saved profile.
// Falls back to a generic prompt when no profile data is available.

enum SystemPrompts {

    // MARK: - Public API

    /// Builds the system prompt for the given user preferences in the device's current locale.
    static func build(for preferences: UserPreferences) -> String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return lang == "es" ? buildSpanish(for: preferences) : buildEnglish(for: preferences)
    }

    // MARK: - Spanish

    private static func buildSpanish(for prefs: UserPreferences) -> String {
        """
        Actúa como mi Entrenador Clínico-Deportivo Senior especializado en longevidad, \
        recomposición metabólica y prevención de deterioro funcional.
        Tu tono debe ser técnico, directo, basado en evidencia científica, pero motivador. \
        Prioriza salud metabólica, fuerza funcional, prevención de enfermedad cardiovascular \
        y autonomía en la vejez por encima de la estética.

        PERFIL DEL CLIENTE
        \(profileBlockSpanish(prefs))

        \(objectiveBlockSpanish(prefs))
        \(conditionsBlockSpanish(prefs))

        FORMATO DE RESPUESTA OBLIGATORIO:

        📊 ANÁLISIS METABÓLICO CLÍNICO
        [Calorías estimadas, proteína total, fibra, carga glucémica, distribución de macros\
        \(prefs.chronicConditions.isEmpty ? "" : ", impacto en condiciones médicas indicadas")]

        Semáforo del día: [🟢 Verde / 🟡 Amarillo / 🔴 Rojo] — [razón breve]

        🏋️ EVALUACIÓN FUNCIONAL
        [Análisis del entrenamiento, volumen, progresión]

        🩺 LONGEVIDAD Y PREVENCIÓN
        [Observaciones relevantes según el perfil de salud del usuario]

        🎯 MICRO-MISIÓN PARA MAÑANA
        [Un ajuste concreto y accionable]

        REGLAS: Responde SIEMPRE en español. NO uses emojis de caritas, partes del cuerpo, \
        ni cohetes. Para el semáforo usa SOLO los emojis 🟢 🟡 🔴.
        """
    }

    private static func profileBlockSpanish(_ prefs: UserPreferences) -> String {
        var parts: [String] = []

        if let sex = prefs.biologicalSex {
            let sexLabel = sex == .male ? "Hombre" : "Mujer"
            if let year = prefs.birthYear {
                let age = Calendar.current.component(.year, from: Date()) - year
                parts.append("\(sexLabel), \(age) años")
            } else {
                parts.append(sexLabel)
            }
        } else if let year = prefs.birthYear {
            let age = Calendar.current.component(.year, from: Date()) - year
            parts.append("\(age) años")
        }

        var bodyParts: [String] = []
        if let h = prefs.heightCm { bodyParts.append("\(Int(h)) cm") }
        if let w = prefs.weightKg { bodyParts.append("\(formatted(w)) kg") }
        if let bf = prefs.bodyFatPercent { bodyParts.append("% graso est. \(Int(bf))%") }
        if !bodyParts.isEmpty { parts.append(bodyParts.joined(separator: " | ")) }

        if let days = prefs.trainingDaysPerWeek {
            parts.append("Entrena \(days) día\(days == 1 ? "" : "s")/semana")
        }

        if parts.isEmpty {
            return "• Perfil no configurado"
        }
        return parts.map { "• \($0)" }.joined(separator: "\n")
    }

    private static func objectiveBlockSpanish(_ prefs: UserPreferences) -> String {
        guard !prefs.fitnessGoals.isEmpty else {
            return "OBJETIVO CENTRAL: Mejorar la salud general, el bienestar y la calidad de vida."
        }
        let goals = prefs.fitnessGoals.map { $0.displayName }.joined(separator: ", ")
        return "OBJETIVO CENTRAL: \(goals)."
    }

    private static func conditionsBlockSpanish(_ prefs: UserPreferences) -> String {
        var lines: [String] = []
        if !prefs.chronicConditions.isEmpty {
            let list = prefs.chronicConditions.map { $0.displayName }.joined(separator: ", ")
            lines.append("CONDICIONES MÉDICAS: \(list).")
        }
        if let meds = prefs.medications, !meds.trimmingCharacters(in: .whitespaces).isEmpty {
            lines.append("Medicación: \(meds).")
            lines.append("Considera: impacto glucémico, carga renal de proteína, perfil inflamatorio, respuesta cardiovascular.")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - English

    private static func buildEnglish(for prefs: UserPreferences) -> String {
        """
        Act as my Senior Clinical-Sports Coach specializing in longevity, metabolic recomposition, \
        and functional deterioration prevention.
        Your tone should be technical, direct, evidence-based, and motivating. Prioritize metabolic \
        health, functional strength, cardiovascular disease prevention, and autonomy in old age over \
        aesthetics.

        CLIENT PROFILE
        \(profileBlockEnglish(prefs))

        \(objectiveBlockEnglish(prefs))
        \(conditionsBlockEnglish(prefs))

        MANDATORY RESPONSE FORMAT:

        📊 CLINICAL METABOLIC ANALYSIS
        [Estimated calories, total protein, fiber, glycemic load, macro distribution\
        \(prefs.chronicConditions.isEmpty ? "" : ", impact on indicated medical conditions")]

        Day traffic light: [🟢 Green / 🟡 Yellow / 🔴 Red] — [brief reason]

        🏋️ FUNCTIONAL ASSESSMENT
        [Training analysis, volume, progression]

        🩺 LONGEVITY AND PREVENTION
        [Relevant observations based on the user's health profile]

        🎯 TOMORROW'S MICRO-MISSION
        [One concrete, actionable adjustment]

        RULES: Always respond in English. Do NOT use face, body part, or rocket emojis. \
        For the traffic light use ONLY the emojis 🟢 🟡 🔴.
        """
    }

    private static func profileBlockEnglish(_ prefs: UserPreferences) -> String {
        var parts: [String] = []

        if let sex = prefs.biologicalSex {
            let sexLabel = sex == .male ? "Male" : "Female"
            if let year = prefs.birthYear {
                let age = Calendar.current.component(.year, from: Date()) - year
                parts.append("\(sexLabel), \(age) years old")
            } else {
                parts.append(sexLabel)
            }
        } else if let year = prefs.birthYear {
            let age = Calendar.current.component(.year, from: Date()) - year
            parts.append("\(age) years old")
        }

        var bodyParts: [String] = []
        if let h = prefs.heightCm { bodyParts.append("\(Int(h)) cm") }
        if let w = prefs.weightKg { bodyParts.append("\(formatted(w)) kg") }
        if let bf = prefs.bodyFatPercent { bodyParts.append("Est. body fat \(Int(bf))%") }
        if !bodyParts.isEmpty { parts.append(bodyParts.joined(separator: " | ")) }

        if let days = prefs.trainingDaysPerWeek {
            parts.append("Trains \(days) day\(days == 1 ? "" : "s")/week")
        }

        if parts.isEmpty {
            return "• Profile not configured"
        }
        return parts.map { "• \($0)" }.joined(separator: "\n")
    }

    private static func objectiveBlockEnglish(_ prefs: UserPreferences) -> String {
        guard !prefs.fitnessGoals.isEmpty else {
            return "CENTRAL OBJECTIVE: Improve general health, wellbeing, and quality of life."
        }
        let goals = prefs.fitnessGoals.map { $0.displayName }.joined(separator: ", ")
        return "CENTRAL OBJECTIVE: \(goals)."
    }

    private static func conditionsBlockEnglish(_ prefs: UserPreferences) -> String {
        var lines: [String] = []
        if !prefs.chronicConditions.isEmpty {
            let list = prefs.chronicConditions.map { $0.displayName }.joined(separator: ", ")
            lines.append("MEDICAL CONDITIONS: \(list).")
        }
        if let meds = prefs.medications, !meds.trimmingCharacters(in: .whitespaces).isEmpty {
            lines.append("Medication: \(meds).")
            lines.append("Consider: glycemic impact, protein renal load, inflammatory profile, cardiovascular response.")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private static func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}
