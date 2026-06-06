import Foundation

// MARK: - SystemPrompts
// Builds the clinical-sports system prompt dynamically from the user's saved profile.
// Section markers ([METABOLIC], [FUNCTIONAL], [LONGEVITY], [MISSION]) are fixed ASCII
// tags — independent of response language — so AnalysisTextParser can parse them reliably.

enum SystemPrompts {

    // MARK: - Public API

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

        FORMATO DE RESPUESTA OBLIGATORIO — devuelve ÚNICAMENTE un objeto JSON válido.
        Sin comillas de código, sin texto antes ni después. Sigue este esquema exacto.
        Las 5 secciones son obligatorias; si no hay datos usa 0 en los campos numéricos.

        {
          "trafficLight": "green|yellow|red",
          "title": "Reporte Diario",
          "subtitle": "Síntesis fisiológica, nutricional y metabólica",
          "sections": [
            {
              "id": "fisiologico", "number": 1,
              "title": "Análisis Fisiológico Breve",
              "type": "richText",
              "blocks": [
                {"type":"p","md":"Párrafo con **negritas** e *itálicas* permitidas."}
              ]
            },
            {
              "id": "macros", "number": 2,
              "title": "Desglose de Macronutrientes y Calorías",
              "type": "meals",
              "note": "Nota opcional sobre estimaciones de pesos y porciones.",
              "meals": [
                {
                  "id": "desayuno", "label": "Desayuno", "subtitle": "Descripción energética",
                  "items": [{"name":"Alimento","portion":"porción","protein":0,"carbs":0,"fat":0,"kcal":0}]
                },
                {"id":"comida","label":"Comida","subtitle":"...","items":[{"name":"...","portion":"...","protein":0,"carbs":0,"fat":0,"kcal":0}]},
                {"id":"cena","label":"Cena","subtitle":"...","items":[{"name":"...","portion":"...","protein":0,"carbs":0,"fat":0,"kcal":0}]},
                {"id":"snack","label":"Snack","subtitle":"...","items":[{"name":"...","portion":"...","protein":0,"carbs":0,"fat":0,"kcal":0}]}
              ]
            },
            {
              "id": "totales", "number": 3,
              "title": "Resumen Total del Día",
              "type": "totals",
              "totals": {"protein":0,"carbs":0,"fat":0,"kcal":0},
              "commentary": [
                {"key":"protein","title":"Proteína","text":"Análisis cualitativo."},
                {"key":"carbs","title":"Carbohidratos","text":"Análisis cualitativo."},
                {"key":"fat","title":"Grasas","text":"Análisis cualitativo."},
                {"key":"kcal","title":"Calorías","text":"Análisis cualitativo."}
              ]
            },
            {
              "id": "renal", "number": 4,
              "title": "Semáforo de Salud Renal",
              "type": "renal",
              "subtitle": "Directrices NKF",
              "rows": [
                {"items":"lista de alimentos","status":"green","label":"Verde","reason":"Razón clínica."}
              ],
              "callout": {"icon":"💧","title":"Balance Hidroelectrolítico","text":"Análisis con **negritas** permitidas."}
            },
            {
              "id": "metabolico", "number": 5,
              "title": "Diagnóstico Metabólico",
              "type": "bullets",
              "bullets": [{"title":"Título del punto","text":"Descripción detallada del diagnóstico."}]
            }
          ]
        }

        REGLAS: Devuelve ÚNICAMENTE el JSON — sin texto antes ni después, sin comillas de código.
        Para el campo trafficLight usa exactamente "green", "yellow" o "red" (en inglés, sin emojis).
        Responde SIEMPRE en español en todos los campos de texto del JSON.
        NO uses emojis de caritas, partes del cuerpo ni cohetes (excepto 💧 en el callout si aplica).
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

        return parts.isEmpty ? "• Perfil no configurado" : parts.map { "• \($0)" }.joined(separator: "\n")
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

        MANDATORY RESPONSE FORMAT — return ONLY a valid JSON object.
        No code fences, no text before or after. Follow this schema exactly.
        All 5 sections are required; use 0 for numeric fields when data is missing.

        {
          "trafficLight": "green|yellow|red",
          "title": "Daily Report",
          "subtitle": "Physiological, nutritional and metabolic synthesis",
          "sections": [
            {
              "id": "physiological", "number": 1,
              "title": "Brief Physiological Analysis",
              "type": "richText",
              "blocks": [
                {"type":"p","md":"Paragraph with **bold** and *italic* allowed."}
              ]
            },
            {
              "id": "macros", "number": 2,
              "title": "Macronutrient and Calorie Breakdown",
              "type": "meals",
              "note": "Optional note about portion and weight estimates.",
              "meals": [
                {
                  "id": "breakfast", "label": "Breakfast", "subtitle": "Energy description",
                  "items": [{"name":"Food","portion":"portion","protein":0,"carbs":0,"fat":0,"kcal":0}]
                },
                {"id":"lunch","label":"Lunch","subtitle":"...","items":[{"name":"...","portion":"...","protein":0,"carbs":0,"fat":0,"kcal":0}]},
                {"id":"dinner","label":"Dinner","subtitle":"...","items":[{"name":"...","portion":"...","protein":0,"carbs":0,"fat":0,"kcal":0}]},
                {"id":"snack","label":"Snack","subtitle":"...","items":[{"name":"...","portion":"...","protein":0,"carbs":0,"fat":0,"kcal":0}]}
              ]
            },
            {
              "id": "totals", "number": 3,
              "title": "Daily Summary",
              "type": "totals",
              "totals": {"protein":0,"carbs":0,"fat":0,"kcal":0},
              "commentary": [
                {"key":"protein","title":"Protein","text":"Qualitative analysis."},
                {"key":"carbs","title":"Carbohydrates","text":"Qualitative analysis."},
                {"key":"fat","title":"Fat","text":"Qualitative analysis."},
                {"key":"kcal","title":"Calories","text":"Qualitative analysis."}
              ]
            },
            {
              "id": "renal", "number": 4,
              "title": "Renal Health Semaphore",
              "type": "renal",
              "subtitle": "NKF Guidelines",
              "rows": [
                {"items":"food list","status":"green","label":"Green","reason":"Clinical reason."}
              ],
              "callout": {"icon":"💧","title":"Hydroelectrolyte Balance","text":"Analysis with **bold** allowed."}
            },
            {
              "id": "metabolic", "number": 5,
              "title": "Metabolic Diagnosis",
              "type": "bullets",
              "bullets": [{"title":"Point title","text":"Detailed diagnosis description."}]
            }
          ]
        }

        RULES: Return ONLY the JSON — no text before or after, no code fences.
        For the trafficLight field use exactly "green", "yellow" or "red" (no emojis).
        Always respond in English in all text fields of the JSON.
        Do NOT use face, body part, or rocket emojis (💧 in callout is allowed if relevant).
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

        return parts.isEmpty ? "• Profile not configured" : parts.map { "• \($0)" }.joined(separator: "\n")
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
