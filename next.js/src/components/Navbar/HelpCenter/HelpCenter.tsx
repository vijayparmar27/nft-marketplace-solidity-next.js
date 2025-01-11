import React from "react";
import Link from "next/link";

//INTERNAL IMPORT
import Style from "./HelpCenter.module.css";

interface IHelpCenter {
  name: string;
  link: string;
}

const HelpCenter = () => {
  const helpCenter: IHelpCenter[] = [
    {
      name: "About",
      link: "about",
    },
    {
      name: "Contact Us",
      link: "contact-us",
    },
    {
      name: "Sign Up",
      link: "sign-up",
    },
    {
      name: "Sign In",
      link: "sign-in",
    },
    {
      name: "Subscription",
      link: "subscription",
    },
  ];
  return (
    <div className={Style.box}>
      {helpCenter.map((el: IHelpCenter, i: number) => (
        <div className={Style.helpCenter} key={`${el.link}-${el.name}-${i}`}>
          <Link href={{ pathname: `${el.link}` }}>{el.name}</Link>
        </div>
      ))}
    </div>
  );
};

export default HelpCenter;
