import Foundation
import Security

// MARK: - KeychainService

enum KeychainService {

    // MARK: - Errors

    enum KeychainError: Error, LocalizedError {
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)

        var errorDescription: String? {
            switch self {
            case .itemNotFound:               return Strings.Error.keychainNotFound
            case .duplicateItem:              return Strings.Error.keychainDuplicate
            case .unexpectedStatus(let code): return Strings.Error.keychainUnexpected(code)
            }
        }
    }

    // MARK: - CRUD

    static func save(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing before saving to avoid duplicates
        try? delete(key: key)

        let query: [CFString: Any] = [
            kSecClass:           kSecClassGenericPassword,
            kSecAttrAccount:     key,
            kSecValueData:       data,
            kSecAttrAccessible:  kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func get(key: String) throws -> String {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      key,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound { throw KeychainError.itemNotFound }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.itemNotFound
        }

        return value
    }

    static func delete(key: String) throws {
        let query: [CFString: Any] = [
            kSecClass:        kSecClassGenericPassword,
            kSecAttrAccount:  key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
