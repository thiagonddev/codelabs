import imgURL from "../assets/programming.jpg";

function Headline() {
  return (
    <section
      className="grid items-center gap-12 md:grid-cols-2"
      aria-labelledby="hero-title"
    >
      <div className="flex flex-col gap-6">
        <h1
          id="hero-title"
          className="text-5xl font-extrabold tracking-tight text-zinc-900 dark:text-white"
        >
          Wassup!
        </h1>

        <p className="max-w-lg text-lg leading-8 text-zinc-600 dark:text-zinc-300">
          Get ready to impress yourself with all the projects made by Thiago!
        </p>

        <a
          href="/projects"
          className="w-fit rounded-lg bg-blue-600 px-6 py-3 font-medium text-white transition hover:bg-blue-700 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2"
        >
          View Projects
        </a>
      </div>

      <img
        src={imgURL}
        alt="Developer working on a programming project"
        className="w-full rounded-2xl shadow-xl"
      />
    </section>
  );
}

export default function Hero() {
  return (
    <main className="mx-auto max-w-7xl px-6 py-16">
      <Headline />
    </main>
  );
}