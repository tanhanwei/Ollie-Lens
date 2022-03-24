import type { NextPage } from 'next'
import { useState, useEffect } from "react";
import { useTheme } from "next-themes";
import Head from "next/head";

const Home: NextPage = () => {
  const [isMounted, setIsMounted] = useState(false);
  const { theme, setTheme } = useTheme();

  useEffect(() => {
    setIsMounted(true);
  }, []);

  const switchTheme = () => {
    if (isMounted) {
      setTheme(theme === "light" ? "dark" : "light");
    }
  };

  return (
    <div className="text-center">
      <Head>
        <title>Lens</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <body>
        <h1 className="text:2xl">Welcome</h1>
      </body>
    </div>
  );
};

export default Home
