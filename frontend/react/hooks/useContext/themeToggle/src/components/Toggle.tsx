import { useTheme } from "../hooks/useTheme";

export default function Toggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <label className="relative inline-flex items-center cursor-pointer gap-3">
      <input
        type="checkbox"
        className="sr-only peer"
        onChange={toggleTheme}
        checked={theme === "dark"}
        aria-label="Toggle dark mode"
      />

      <div className="w-12 h-7 bg-slate-300 rounded-full peer peer-checked:bg-indigo-600 transition-colors duration-200" />

      <span className="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform duration-200 ease-in-out peer-checked:translate-x-5" />
    </label>
  );
}
