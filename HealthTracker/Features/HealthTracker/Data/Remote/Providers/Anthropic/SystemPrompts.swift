import Foundation

// MARK: - SystemPrompts
// Builds the clinical-sports system prompt dynamically from the user's saved profile.
// The JSON sections schema is built at runtime: sections 1–3 and the metabolic bullets
// are always present; condition impacts and renal sections are injected only when the
// user has the corresponding conditions selected in their health profile.

enum SystemPrompts {

    // MARK: - Public API

    static func build(for preferences: UserPreferences) -> String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        return lang == "es" ? buildSpanish(for: preferences) : buildEnglish(for: preferences)
    }

    // MARK: - Spanish

    private static func buildSpanish(for prefs: UserPreferences) -> String {
        let sectionsCount = 3
            + (prefs.chronicConditions.isEmpty ? 0 : 1)
            + 1
            + 1
        return """
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
        El JSON tendrá \(sectionsCount) secciones; si no hay datos usa 0 en los campos numéricos.

        {
          "trafficLight": "green|yellow|red",
          "title": "Reporte Diario",
          "subtitle": "Síntesis fisiológica, nutricional y metabólica",
          "sections": [
            \(sectionSchemaSpanish(prefs))
          ]
        }

        REGLAS: Devuelve ÚNICAMENTE el JSON — sin texto antes ni después, sin comillas de código.
        Incluye SOLO las secciones listadas en el esquema anterior. No inventes secciones adicionales.
        Para el campo trafficLight usa exactamente "green", "yellow" o "red" (en inglés, sin emojis).
        Responde SIEMPRE en español en todos los campos de texto del JSON.
        NO uses emojis de caritas, partes del cuerpo ni cohetes (excepto 💧 en el callout si aplica).
        Cada viñeta bajo un horario de comida en los datos es un alimento registrado individualmente \
        por el usuario. Mapea cada viñeta a exactamente un ítem en el array "items" del JSON — no \
        fusiones viñetas separadas en un solo ítem, ni dividas una única viñeta en varios ítems.
        Para el objeto "targets" en la sección de totales, calcula valores mín/óptimo/máx basados \
        en evidencia científica según el perfil del cliente (peso, talla, % graso, objetivos, \
        condiciones médicas y nivel de actividad de hoy). "optimal" es el objetivo ideal para el día; \
        "min" es el piso clínico por debajo del cual el déficit resulta perjudicial; "max" es el \
        techo a partir del cual el exceso contrarresta los objetivos declarados.
        """
    }

    private static func sectionSchemaSpanish(_ prefs: UserPreferences) -> String {
        var number   = 3
        var sections: [String] = []

        sections.append("""
        {
              "id": "fisiologico", "number": 1,
              "title": "Análisis Fisiológico Breve",
              "type": "richText",
              "blocks": [
                {"type":"p","md":"Párrafo con **negritas** e *itálicas* permitidas."}
              ]
            }
        """)

        sections.append("""
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
            }
        """)

        sections.append("""
        {
              "id": "totales", "number": 3,
              "title": "Resumen Total del Día",
              "type": "totals",
              "totals": {"protein":0,"carbs":0,"fat":0,"kcal":0},
              "targets": {
                "protein": {"min":0,"optimal":0,"max":0},
                "carbs":   {"min":0,"optimal":0,"max":0},
                "fat":     {"min":0,"optimal":0,"max":0},
                "kcal":    {"min":0,"optimal":0,"max":0}
              },
              "commentary": [
                {"key":"protein","title":"Proteína","text":"Análisis cualitativo."},
                {"key":"carbs","title":"Carbohidratos","text":"Análisis cualitativo."},
                {"key":"fat","title":"Grasas","text":"Análisis cualitativo."},
                {"key":"kcal","title":"Calorías","text":"Análisis cualitativo."}
              ]
            }
        """)

        if !prefs.chronicConditions.isEmpty {
            number += 1
            let impactItems = prefs.chronicConditions.map { c -> String in
                if c == .renalDisease {
                    return """
                    {"id":"\(c.rawValue)","title":"\(c.displayName)","trafficLight":"green|yellow|red","text":"Evaluación clínica general del impacto renal de la ingesta y actividad de hoy.","rows":[{"items":"lista de alimentos","status":"green","label":"Verde","reason":"Razón clínica NKF."}]}
                    """
                }
                return """
                {"id":"\(c.rawValue)","title":"\(c.displayName)","trafficLight":"green|yellow|red","text":"Análisis clínico detallado del impacto de la ingesta y actividad de hoy en \(c.displayName)."}
                """
            }.joined(separator: ",\n                ")
            sections.append("""
            {
                  "id": "conditions", "number": \(number),
                  "title": "Impacto en tus Condiciones de Salud",
                  "type": "conditionImpacts",
                  "impacts": [
                    \(impactItems)
                  ]
                }
            """)
        }

        number += 1
        sections.append("""
        {
              "id": "hidratacion", "number": \(number),
              "title": "Hidratación",
              "type": "hydration",
              "callout": {"icon":"💧","title":"Balance Hidroelectrolítico","text":"Análisis sobre la idoneidad del consumo de agua de hoy con **negritas** permitidas."}
            }
        """)

        number += 1
        sections.append("""
        {
              "id": "metabolico", "number": \(number),
              "title": "Diagnóstico Metabólico",
              "type": "bullets",
              "bullets": [{"title":"Título del punto","text":"Descripción detallada del diagnóstico."}]
            }
        """)

        return sections.joined(separator: ",\n            ")
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
        let sectionsCount = 3
            + (prefs.chronicConditions.isEmpty ? 0 : 1)
            + 1
            + 1
        return """
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
        The JSON will have \(sectionsCount) sections; use 0 for numeric fields when data is missing.

        {
          "trafficLight": "green|yellow|red",
          "title": "Daily Report",
          "subtitle": "Physiological, nutritional and metabolic synthesis",
          "sections": [
            \(sectionSchemaEnglish(prefs))
          ]
        }

        RULES: Return ONLY the JSON — no text before or after, no code fences.
        Include ONLY the sections listed in the schema above. Do not add extra sections.
        For the trafficLight field use exactly "green", "yellow" or "red" (no emojis).
        Always respond in English in all text fields of the JSON.
        Do NOT use face, body part, or rocket emojis (💧 in callout is allowed if relevant).
        Each bullet under a meal slot in the input is a separate food entry the user logged \
        individually. Map each bullet to exactly one item in the JSON "items" array — do not \
        merge multiple bullets into one item, and do not split a single bullet into multiple items.
        For the "targets" object in the totals section, calculate evidence-based min/optimal/max \
        values for each macro based on the client profile (weight, height, body-fat %, goals, \
        medical conditions, and today's activity level). "optimal" is the ideal single-day target; \
        "min" is the clinical floor below which deficit becomes harmful; "max" is the ceiling \
        above which excess becomes counter-productive for the stated goals.
        """
    }

    private static func sectionSchemaEnglish(_ prefs: UserPreferences) -> String {
        var number   = 3
        var sections: [String] = []

        sections.append("""
        {
              "id": "physiological", "number": 1,
              "title": "Brief Physiological Analysis",
              "type": "richText",
              "blocks": [
                {"type":"p","md":"Paragraph with **bold** and *italic* allowed."}
              ]
            }
        """)

        sections.append("""
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
            }
        """)

        sections.append("""
        {
              "id": "totals", "number": 3,
              "title": "Daily Summary",
              "type": "totals",
              "totals": {"protein":0,"carbs":0,"fat":0,"kcal":0},
              "targets": {
                "protein": {"min":0,"optimal":0,"max":0},
                "carbs":   {"min":0,"optimal":0,"max":0},
                "fat":     {"min":0,"optimal":0,"max":0},
                "kcal":    {"min":0,"optimal":0,"max":0}
              },
              "commentary": [
                {"key":"protein","title":"Protein","text":"Qualitative analysis."},
                {"key":"carbs","title":"Carbohydrates","text":"Qualitative analysis."},
                {"key":"fat","title":"Fat","text":"Qualitative analysis."},
                {"key":"kcal","title":"Calories","text":"Qualitative analysis."}
              ]
            }
        """)

        if !prefs.chronicConditions.isEmpty {
            number += 1
            let impactItems = prefs.chronicConditions.map { c -> String in
                if c == .renalDisease {
                    return """
                    {"id":"\(c.rawValue)","title":"\(c.displayName)","trafficLight":"green|yellow|red","text":"Overall clinical assessment of the renal impact from today's intake and activity.","rows":[{"items":"food list","status":"green","label":"Green","reason":"NKF clinical reason."}]}
                    """
                }
                return """
                {"id":"\(c.rawValue)","title":"\(c.displayName)","trafficLight":"green|yellow|red","text":"Detailed clinical analysis of how today's intake and activity impact \(c.displayName)."}
                """
            }.joined(separator: ",\n                ")
            sections.append("""
            {
                  "id": "conditions", "number": \(number),
                  "title": "Impact on Your Health Conditions",
                  "type": "conditionImpacts",
                  "impacts": [
                    \(impactItems)
                  ]
                }
            """)
        }

        number += 1
        sections.append("""
        {
              "id": "hydration", "number": \(number),
              "title": "Hydration",
              "type": "hydration",
              "callout": {"icon":"💧","title":"Hydroelectrolyte Balance","text":"Analysis of today's water intake optimality with **bold** allowed."}
            }
        """)

        number += 1
        sections.append("""
        {
              "id": "metabolic", "number": \(number),
              "title": "Metabolic Diagnosis",
              "type": "bullets",
              "bullets": [{"title":"Point title","text":"Detailed diagnosis description."}]
            }
        """)

        return sections.joined(separator: ",\n            ")
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
