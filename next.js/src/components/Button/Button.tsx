import React, { ReactNode } from "react";

import Style from "./Button.module.css";
// Props type for the Button component
interface ButtonProps {
  btnName: string;
  handleClick: () => void;
  icon?: ReactNode; // Optional prop for an icon
  classStyle?: string; // Optional string for custom class styles
}

const Button: React.FC<ButtonProps> = ({
  btnName,
  handleClick,
  icon,
  classStyle,
}) => {
  return (
    <div className={Style.box}>
      <button
        className={`${Style.button} ${classStyle || ""}`} // Fallback to an empty string if classStyle is undefined
        onClick={handleClick}
      >
        {icon} {btnName}
      </button>
    </div>
  );
};

export default Button;
