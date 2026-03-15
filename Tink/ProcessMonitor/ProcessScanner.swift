// ProcessScanner.swift
// Tink
//
// Scans BSD processes to find running AI tools (macOS only)

#if os(macOS)
import Foundation
import Darwin
import Darwin.POSIX

struct BSDProcess {
    let pid: pid_t
    let name: String
    let fullPath: String?
}

final class ProcessScanner {
    static let defaultTargets: [(name: String, displayName: String)] = [
        ("claude", "Claude Code"),
        ("codex", "Codex"),
        ("gemini", "Gemini CLI"),
        ("aider", "Aider"),
        ("copilot", "GitHub Copilot"),
        ("cursor-agent", "Cursor Agent"),
    ]

    func scanForTargets(_ targets: [String]) -> [BSDProcess] {
        let allProcs = allBSDProcesses()
        return allProcs.filter { proc in
            targets.contains(where: { proc.name == $0 || proc.fullPath?.contains($0) == true })
        }
    }

    func allBSDProcesses() -> [BSDProcess] {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var bufferSize = 0

        guard sysctl(&mib, UInt32(mib.count), nil, &bufferSize, nil, 0) == 0 else { return [] }

        let entryCount = bufferSize / MemoryLayout<kinfo_proc>.stride
        let procList = UnsafeMutablePointer<kinfo_proc>.allocate(capacity: entryCount)
        defer { procList.deallocate() }

        guard sysctl(&mib, UInt32(mib.count), procList, &bufferSize, nil, 0) == 0 else { return [] }

        return (0..<entryCount).compactMap { i in
            let pid = procList[i].kp_proc.p_pid
            guard pid > 0 else { return nil }
            let comm = procList[i].kp_proc.p_comm
            let name = withUnsafePointer(to: comm) {
                $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: comm)) {
                    String(cString: $0)
                }
            }
            let fullPath = Self.fullPath(for: pid)
            return BSDProcess(pid: pid, name: name, fullPath: fullPath)
        }
    }

    private static let maxPathSize = 4 * 1024 // PROC_PIDPATHINFO_MAXSIZE = 4096

    private static func fullPath(for pid: pid_t) -> String? {
        let buf = UnsafeMutablePointer<CChar>.allocate(capacity: maxPathSize)
        defer { buf.deallocate() }
        let ret = proc_pidpath(pid, buf, UInt32(maxPathSize))
        return ret > 0 ? String(cString: buf) : nil
    }
}
#endif
