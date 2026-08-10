import Toggle from "./Toggle";

type Labels = "Home" | "About" | "Contact";

type Links = "/" | "/about" | "/contact";

type NavItems = {
  label: Labels;
  url: Links;
};

export const navItems: NavItems[] = [
  {
    label: "Home",
    url: "/",
  },
  {
    label: "About",
    url: "/about",
  },
  {
    label: "Contact",
    url: "/contact",
  },
];

function NavLinks() {
  return (
    <nav aria-label="Primary navigation">
      <ul className="flex items-center gap-6 font-medium">
        {navItems.map((item) => (
          <li key={item.url}>
            <a
              href={item.url}
              className="rounded-md px-2 py-1 transition-colors hover:text-blue-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
            >
              {item.label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}

export default function Navbar() {
  return (
    <header className="sticky top-0 z-50 border-b border-zinc-200 bg-white/80 backdrop-blur dark:border-zinc-800 dark:bg-zinc-900/80">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
        <a
          href="/"
          className="text-xl font-bold text-zinc-900 dark:text-white"
        >
          thiagond
        </a>

        <NavLinks />

        <Toggle />
      </div>
    </header>
  );
}