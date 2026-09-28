# Windows supplies -p and -tid when invoking a package launch helper.
[CmdletBinding()]
param(
    [Alias('p')][Parameter(Mandatory = $true)][int]$ProcessId,
    [Alias('tid')][Parameter(Mandatory = $true)][int]$ThreadId
)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class ProxyFixThreadResumer {
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern IntPtr OpenProcess(uint access, bool inherit, uint pid);
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern IntPtr OpenThread(uint access, bool inherit, uint tid);
    [DllImport("kernel32.dll")]
    static extern uint GetProcessIdOfThread(IntPtr thread);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode)]
    static extern int GetPackageFullName(IntPtr process, ref uint length, StringBuilder name);
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern uint ResumeThread(IntPtr thread);
    [DllImport("kernel32.dll")]
    static extern bool CloseHandle(IntPtr handle);
    public static void Resume(uint pid, uint tid) {
        IntPtr process = OpenProcess(0x1000, false, pid);
        IntPtr thread = IntPtr.Zero;
        try {
            if (process == IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
            uint length = 0;
            if (GetPackageFullName(process, ref length, null) != 122)
                throw new InvalidOperationException("Target has no package identity.");
            var name = new StringBuilder((int)length);
            if (GetPackageFullName(process, ref length, name) != 0 ||
                !(name.ToString().StartsWith("OpenAI.Codex_") || name.ToString().StartsWith("OpenAI.ChatGPT_")))
                throw new InvalidOperationException("Target is not the ChatGPT package.");
            thread = OpenThread(0x0002 | 0x0800, false, tid);
            if (thread == IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
            if (GetProcessIdOfThread(thread) != pid) throw new InvalidOperationException("Thread/process mismatch.");
            if (ResumeThread(thread) == UInt32.MaxValue) throw new System.ComponentModel.Win32Exception();
        } finally {
            if (thread != IntPtr.Zero) CloseHandle(thread);
            if (process != IntPtr.Zero) CloseHandle(process);
        }
    }
}
'@
[ProxyFixThreadResumer]::Resume([uint32]$ProcessId, [uint32]$ThreadId)
