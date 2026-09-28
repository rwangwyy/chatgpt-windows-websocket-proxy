using System;
using System.Runtime.InteropServices;

namespace ProxyFix
{
    // The declared methods are the first slots in each COM interface's vtable.
    [ComImport, Guid("F27C3930-8029-4AD1-94E3-3DBA417810C1"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IPackageDebugSettings
    {
        void EnableDebugging([MarshalAs(UnmanagedType.LPWStr)] string packageFullName,
            [MarshalAs(UnmanagedType.LPWStr)] string debuggerCommandLine, IntPtr environment);
        void DisableDebugging([MarshalAs(UnmanagedType.LPWStr)] string packageFullName);
    }

    [ComImport, Guid("2E941141-7F97-4756-BA1D-9DECDE894A3D"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IApplicationActivationManager
    {
        void ActivateApplication([MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
            [MarshalAs(UnmanagedType.LPWStr)] string arguments, uint options, out uint processId);
    }

    public static class PackageLauncher
    {
        public static uint Start(string packageFullName, string appUserModelId, string[] environment, string resumeCommand)
        {
            object debugObject = null;
            object activationObject = null;
            IntPtr environmentBlock = IntPtr.Zero;
            bool enabled = false;
            string stage = "Create activation interfaces";
            try
            {
                debugObject = Activator.CreateInstance(Type.GetTypeFromCLSID(
                    new Guid("B1AEC16F-2383-4852-B0E9-8F0B1DC66B4D")));
                activationObject = Activator.CreateInstance(Type.GetTypeFromCLSID(
                    new Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")));
                // PZZWSTR is a double-NUL-terminated Unicode environment block.
                char[] block = (String.Join("\0", environment) + "\0\0").ToCharArray();
                environmentBlock = Marshal.AllocHGlobal(block.Length * sizeof(char));
                Marshal.Copy(block, 0, environmentBlock, block.Length);
                stage = "EnableDebugging (proxy environment)";
                // Windows rejects a non-null environment with an empty debugger command.
                // This helper only resumes the new primary thread; it does not attach a debugger.
                ((IPackageDebugSettings)debugObject).EnableDebugging(packageFullName, resumeCommand, environmentBlock);
                enabled = true;
                uint processId;
                stage = "ActivateApplication (package identity)";
                ((IApplicationActivationManager)activationObject).ActivateApplication(appUserModelId, "", 2, out processId);
                return processId;
            }
            catch (Exception error)
            {
                throw new InvalidOperationException(String.Format("{0} failed, HRESULT=0x{1:X8}: {2}",
                    stage, error.HResult, error.Message), error);
            }
            finally
            {
                try
                {
                    if (enabled) ((IPackageDebugSettings)debugObject).DisableDebugging(packageFullName);
                }
                finally
                {
                    if (environmentBlock != IntPtr.Zero) Marshal.FreeHGlobal(environmentBlock);
                    if (activationObject != null) Marshal.FinalReleaseComObject(activationObject);
                    if (debugObject != null) Marshal.FinalReleaseComObject(debugObject);
                }
            }
        }
    }
}
