import { navItems } from "./Navbar";

function Logo() {
  return (
    <section className="space-y-4">
      <h2 className="text-lg font-bold text-zinc-900 dark:text-white">
        thiagond
      </h2>

      <p className="max-w-sm text-zinc-600 dark:text-zinc-400">
        Constructing web applications that scale.
      </p>
    </section>
  );
}

function NavLinks() {
  return (
    <nav aria-label="Footer navigation">
      <ul className="flex flex-col gap-3">
        {navItems.map((item) => (
          <li key={item.url}>
            <a
              href={item.url}
              className="rounded-md transition-colors hover:text-blue-600 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
            >
              {item.label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}

export default function Footer() {
  return (
    <footer className="border-t border-zinc-200 bg-zinc-50 dark:border-zinc-800 dark:bg-zinc-900">
      <div className="mx-auto grid max-w-7xl gap-10 px-6 py-12 md:grid-cols-2">
        <Logo />
        <NavLinks />
      </div>
    </footer>
  );
}