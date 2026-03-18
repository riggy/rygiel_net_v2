Post.destroy_all
Project.destroy_all
NowEntry.destroy_all

Post.create!([
  {
    title: "Getting Started with Rails 8",
    body: <<~MD,
      # Getting Started with Rails 8

      Rails 8 is the most batteries-included version yet. Solid Queue replaces Sidekiq, Solid Cache replaces Redis for caching, and Kamal 2 makes zero-downtime deploys trivial.

      ## What's New

      - **Solid Queue** — database-backed job queue, no Redis needed
      - **Solid Cache** — SQLite-backed cache store
      - **Kamal 2** — Docker deployment that actually works

      ## Getting Started

      ```bash
      gem install rails
      rails new myapp --database=sqlite3
      cd myapp && bin/setup
      ```

      The default stack is now surprisingly capable for most applications.
    MD
    published: true,
    published_at: 2.weeks.ago
  },
  {
    title: "Why SQLite in Production Makes Sense Now",
    body: <<~MD,
      # Why SQLite in Production Makes Sense Now

      For years, "use Postgres in production" was the safe answer. That's changing.

      ## The Case for SQLite

      SQLite with WAL mode handles thousands of concurrent reads and hundreds of writes per second. For a personal site, a SaaS with moderate traffic, or any single-server deployment, it's more than enough.

      **The real advantages:**

      - No separate database process to manage
      - Backups are a single file copy
      - Zero network latency on reads
      - Free with the OS

      ## When It Breaks Down

      Multi-server deployments with write-heavy workloads. That's the real boundary. For everything else, stop over-engineering.
    MD
    published: true,
    published_at: 1.week.ago
  },
  {
    title: "Building in Public",
    body: <<~MD,
      # Building in Public

      I've decided to document this site's development openly. Every decision, every trade-off, every mistake.

      ## Why

      Writing about what you build forces clarity. If you can't explain a decision, you probably haven't thought it through.

      ## What I'll Cover

      - Architecture decisions and why I made them
      - Things that broke and how I fixed them
      - Weekly progress notes

      The goal isn't content marketing. It's accountability.
    MD
    published: true,
    published_at: 3.days.ago
  }
])

Project.create!([
  {
    name: "Personal Site",
    description: "Personal homepage and blog built with Rails 8. Minimal dark design, Markdown-powered blog, full admin panel. Deployed via Kamal on a single VPS.",
    tech_tags: "Ruby on Rails, SQLite, Hotwire, Kamal",
    url: "",
    featured: true
  },
  {
    name: "CLI Task Manager",
    description: "Fast terminal-based task manager written in Ruby. Supports projects, priorities, and time tracking with a clean TUI interface.",
    tech_tags: "Ruby, TTY, SQLite",
    url: "https://github.com/",
    featured: true
  },
  {
    name: "Rack Rate Limiter",
    description: "Pluggable rate limiting middleware for Rack applications. Supports sliding window, token bucket, and fixed window algorithms. Redis and in-memory backends.",
    tech_tags: "Ruby, Rack, Redis",
    url: "https://github.com/",
    featured: true
  },
  {
    name: "Dev Dashboard",
    description: "Self-hosted developer dashboard aggregating GitHub activity, uptime monitors, and deployment status in a single live-updating view.",
    tech_tags: "Rails, Turbo Streams, Stimulus",
    url: "",
    featured: false
  }
])

NowEntry.create!(
  content: "Working on a personal Rails 8 site with a blog and project showcase. Reading *The Pragmatic Programmer*. Exploring SQLite internals and WAL-mode tuning for single-server production deployments."
)

puts "Seeded: #{Post.count} posts, #{Project.count} projects, #{NowEntry.count} now entries"

SiteConfig.destroy_all
SiteConfig.create!([
  { key: "hero_tagline", value: "Hi, I'm Jane Doe." },
  { key: "hero_description", value: "Software developer building clean, reliable things for the web." },
  { key: "about_text", value: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. I enjoy working close to the metal — clean architecture, fast deployments, and tools that stay out of the way.\n\nCurrently building with Ruby on Rails, leaning on modern defaults: SQLite, Solid Queue, Kamal. I believe in shipping small, iterating fast, and keeping complexity budget under control." },
  { key: "skills", value: "Ruby, Rails, PostgreSQL, SQLite, Docker, Linux, Git, REST APIs, Hotwire, Stimulus, Kamal, RSpec" },
  { key: "contact", value: "Open to interesting projects and conversations. Reach out via email or find me online." },
  { key: "contact_email", value: "hello@example.com" },
  { key: "contact_github", value: "https://github.com/" },
  { key: "contact_linkedin", value: "https://linkedin.com/" },
  { key: "profile_photo_path", value: "" }
])

puts "Seeded: #{SiteConfig.count} site configs"
