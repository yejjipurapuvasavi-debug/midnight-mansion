# The Midnight Mansion × Department of Nonsense

A responsive, premium dark friendship website starter built with HTML, CSS and JavaScript. It combines the mysterious mansion entrance with the chaotic, meme-style features from The Department of Nonsense.

## Features in this merged prototype

- Cinematic 3D-style mansion door entrance, with a skip button
- Separate room navigation (no need to scroll through the whole site)
- Friend profiles with nicknames, friendship roles, green/red flags, funny lore, awards, optional birthday countdowns and photo URLs
- Roast Lab with playful, savage and compliment modes
- Memory timeline with dates, places, captions and local photo uploads; place names link to a Google Maps search
- Dedication Room for **any song** from any movie, album or artist. Includes Telugu, Hindi, English, Tamil, Malayalam, Kannada, Punjabi, Bengali, Marathi and other/multilingual options
- Search buttons that open YouTube search results for the chosen language/song
- Song dedications with a recipient, note and a link to the song
- Secret messages, optional demo unlock codes and a code decoder
- Compatibility test, random dares and “who knows whom best?” quiz
- Department of Nonsense: fake breaking news, surprise buttons, fake loading-screen plot twist, group-photo Hall of Shame and a fake group-chat simulator
- Mansion statistics for profiles, memories, dedications and Hall of Shame photos
- Responsive layout for phone and laptop
- Small synthesized sound effect; full songs open through the user's chosen streaming links
- Starter Supabase configuration and invite-function files retained from the mansion prototype

## Run locally

1. Extract the ZIP.
2. Open the extracted `midnight_mansion` folder in VS Code.
3. Install the **Live Server** extension (Ritwick Dey) if needed.
4. Open `index.html`, right-click inside it and choose **Open with Live Server**.

You can also open `index.html` directly in a browser for a quick preview, but Live Server is recommended.

## Song-library note

The site is designed so you can dedicate **any song you want**, rather than limiting you to a short preset movie list. Enter the song title, choose a language, and optionally enter the movie/album/artist. Click **Find this song online** or leave the link blank when saving; the project will create a YouTube search link. If you already have an official YouTube/Spotify/streaming URL, paste it into the link field.

It does not include a copy of every song or bundle copyrighted movie audio. That would not be practical or licensed. It searches for the song and links to the streaming source instead. Playback and availability are controlled by that service.

## Important limitations of the current prototype

- Profile, memory, song, secret, chat and gallery content is saved in the **current browser's localStorage**. It does not sync between devices or visitors yet.
- Uploaded photos are stored in browser storage and may use up its quota. Use small test images and avoid private photos until secure shared storage is configured.
- The “unlock code” on secret messages and the demo admin room are playful prototype features, not secure authentication.
- The fake chat is only a local simulator; it does not connect to WhatsApp or send messages.
- Birthday dates and friend information should be shared only with permission.

## To publish a real shared website

1. Create a GitHub repository and upload this project.
2. Import the repository into Vercel to get a public website URL.
3. Create a Supabase project for authentication, database tables and photo storage.
4. Configure `config.js` with the Supabase project URL and **anon/public** key only.
5. Add database tables and Storage policies with Row Level Security. Public visitors should be able to view only what you intentionally publish; only authenticated, invited contributors should be able to create or edit content; only the owner/admin should be able to administer the site.
6. Wire each feature (profiles, memories, songs, secrets and photos) to those protected tables/buckets and test access using a non-admin account before sharing the link.

The included invite function is a starter scaffold, not a complete production-ready access-control system. Shared storage and permissions must be fully implemented and tested before you rely on it for private content. Never put a Supabase service-role key in browser JavaScript.

## Files

- `index.html` — site content and rooms
- `style.css` — dark cinematic visual design and responsive layout
- `script.js` — interactions and local prototype storage
- `config.js` — optional Supabase client configuration
- `supabase/schema.sql` and `supabase/functions/` — starter backend files to review and finish before production
