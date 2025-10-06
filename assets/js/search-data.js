// get the ninja-keys element
const ninja = document.querySelector('ninja-keys');

// add the home and posts menu items
ninja.data = [{
    id: "nav-about",
    title: "about",
    section: "Navigation",
    handler: () => {
      window.location.href = "/";
    },
  },{id: "nav-resume",
          title: "resume",
          description: "",
          section: "Navigation",
          handler: () => {
            window.location.href = "/resume/";
          },
        },{id: "nav-projects",
          title: "projects",
          description: "Some things I&#39;ve worked on!",
          section: "Navigation",
          handler: () => {
            window.location.href = "/projects/";
          },
        },{id: "nav-blog",
          title: "blog",
          description: "",
          section: "Navigation",
          handler: () => {
            window.location.href = "/blog/";
          },
        },{id: "books-the-godfather",
          title: 'The Godfather',
          description: "",
          section: "Books",handler: () => {
              window.location.href = "/books/the_godfather/";
            },},{id: "news-a-simple-inline-announcement",
          title: 'A simple inline announcement.',
          description: "",
          section: "News",},{id: "news-a-long-announcement-with-details",
          title: 'A long announcement with details',
          description: "",
          section: "News",handler: () => {
              window.location.href = "/news/announcement_2/";
            },},{id: "news-a-simple-inline-announcement-with-markdown-emoji-sparkles-smile",
          title: 'A simple inline announcement with Markdown emoji! :sparkles: :smile:',
          description: "",
          section: "News",},{id: "projects-project-2",
          title: 'project 2',
          description: "a project with a background image and giscus comments",
          section: "Projects",handler: () => {
              window.location.href = "/projects/2_project/";
            },},{id: "projects-project-3-with-very-long-name",
          title: 'project 3 with very long name',
          description: "a project that redirects to another website",
          section: "Projects",handler: () => {
              window.location.href = "/projects/3_project/";
            },},{id: "projects-project-4",
          title: 'project 4',
          description: "another without an image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/4_project/";
            },},{id: "projects-project-5",
          title: 'project 5',
          description: "a project with a background image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/5_project/";
            },},{id: "projects-project-6",
          title: 'project 6',
          description: "a project with no image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/6_project/";
            },},{id: "projects-project-7",
          title: 'project 7',
          description: "with background image",
          section: "Projects",handler: () => {
              window.location.href = "/projects/7_project/";
            },},{id: "projects-project-8",
          title: 'project 8',
          description: "an other project with a background image and giscus comments",
          section: "Projects",handler: () => {
              window.location.href = "/projects/8_project/";
            },},{id: "projects-project-9",
          title: 'project 9',
          description: "another project with an image 🎉",
          section: "Projects",handler: () => {
              window.location.href = "/projects/9_project/";
            },},{id: "projects-eventify",
          title: 'Eventify',
          description: "On-campus event finding site built with an ACM project group",
          section: "Projects",handler: () => {
              window.location.href = "/projects/eventify/";
            },},{id: "projects-fractal-noise-visualizer",
          title: 'Fractal Noise Visualizer',
          description: "Implemented 1D fractal noise and built a simple visualizer in Godot with parameter control",
          section: "Projects",handler: () => {
              window.location.href = "/projects/fractal-visualizer/";
            },},{id: "projects-gavyn-39-s-voyage",
          title: 'Gavyn&amp;#39;s Voyage',
          description: "A former 3D personal website I had used for myself, built in Three.js",
          section: "Projects",handler: () => {
              window.location.href = "/projects/gavyns-voyage/";
            },},{id: "projects-raytracer",
          title: 'raytracer',
          description: "Built a simple 3D raytracing engine in C++",
          section: "Projects",handler: () => {
              window.location.href = "/projects/raytracer/";
            },},{id: "projects-super-smash-bros-player-tracker",
          title: 'Super Smash Bros. Player Tracker',
          description: "A web app for keeping track of your favorite competitors in the Super Smash Bros. eSports scene.",
          section: "Projects",handler: () => {
              window.location.href = "/projects/ssbu-player-tracker/";
            },},{id: "projects-double-elimination-bracket-generator",
          title: 'Double Elimination Bracket Generator',
          description: "Simple web app for visualizing double elimination brackets with fair seed placement.",
          section: "Projects",handler: () => {
              window.location.href = "/projects/twoframe-bracket-generator/";
            },},{id: "projects-twoframe",
          title: 'TwoFrame',
          description: "Built a fullstack website for managing video game tournaments",
          section: "Projects",handler: () => {
              window.location.href = "/projects/twoframe/";
            },},{id: "projects-vr-air-race",
          title: 'VR Air Race',
          description: "A basic VR air racing game for a 3D user interaction class",
          section: "Projects",handler: () => {
              window.location.href = "/projects/vr-air-race/";
            },},{id: "projects-vr-drummer",
          title: 'VR Drummer',
          description: "A basic VR Drummer game built for a 3D user interaction class",
          section: "Projects",handler: () => {
              window.location.href = "/projects/vr-drummer/";
            },},{
      id: 'light-theme',
      title: 'Change theme to light',
      description: 'Change the theme of the site to Light',
      section: 'Theme',
      handler: () => {
        setThemeSetting("light");
      },
    },
    {
      id: 'dark-theme',
      title: 'Change theme to dark',
      description: 'Change the theme of the site to Dark',
      section: 'Theme',
      handler: () => {
        setThemeSetting("dark");
      },
    },
    {
      id: 'system-theme',
      title: 'Use system default theme',
      description: 'Change the theme of the site to System Default',
      section: 'Theme',
      handler: () => {
        setThemeSetting("system");
      },
    },];
