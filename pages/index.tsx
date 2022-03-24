import type { NextPage } from 'next'
import dynamic from "next/dynamic";
import { useState, useEffect } from "react";
import { useTheme } from "next-themes";
import Head from "next/head";
import Image from "next/image";

import { createProfile } from "../scripts/create-profile";
import { login } from "../scripts/login-user";

const Home: NextPage = () => {
  const [isMounted, setIsMounted] = useState(false);
  const [authData, setAuthData] = useState(null);

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

      <div className="container mx-auto bg-[#071B2A] m-4 p-10 rounded">
        LOGO
      </div>

      <div className="container mx-auto bg-[#071B2A] m-4 p-10 rounded">
        <h1 className="text:2xl">Welcome</h1>

        <div className="flex flex-col">
          <button
            className="bg-indigo-500 p-4 mt-4 rounded-md"
            onClick={async () => {
              const response = await createProfile();
              alert(JSON.stringify(response.data));
            }}
          >
            Create Profile
          </button>
          <button
            className="bg-indigo-500 p-4 mt-4 rounded-md"
            onClick={async () => {
              const response: any = await login();

              const data = response?.data?.authenticate;
              localStorage.setItem("auth_token", data?.accessToken);
              localStorage.setItem("refresh_token", data?.refreshToken);
            }}
          >
            Login
          </button>
        </div>
      </div>

      <Image
        src="/footer.svg"
        height="700"
        width="1500"
        className="-z-10 fixed bottom-0 fixed"
      />
    </div>
  );
};

export default Home
