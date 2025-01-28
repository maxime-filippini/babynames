# babynames

Simple web app for voting on baby names.

## To do

- [x] Set up PostgreSQL database on the server
- [x] Set up Squirrel
- [x] Set up some basic tables
- [x] Build simple auth (Google OAuth)
- [x] Add script argument to change the port
- [x] Build the index page using `lustre` rather than an html file
- [x] Refactor folders into routers and html
- [ ] Add functions for building protected routes, i.e. using a User object stored in context.
- [ ] Implement authorized vs unauthorized users
- [x] Use tailwind CLI on gleam files directly, remove the build step (tailwind doesn't parse files, and instead just finds strings that match their class names, so it'll work [ref](https://tailwindcss.com/docs/detecting-classes-in-source-files))
- [ ] Implement file watcher and hot reload based on what is done in `lustre-dev-tools` 
