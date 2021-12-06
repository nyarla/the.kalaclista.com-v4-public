"use strict";

import { loadDefaultJapaneseParser } from "budoux";

const parser = loadDefaultJapaneseParser();

window.addEventListener("DOMContentLoaded", () => {
  const elements = document.querySelectorAll(
    [
      ".entry .entry__content p",
      ".entry h1",
      ".entry h2",
      ".entry h3",
      ".entry h4",
      ".entry h5",
      ".entry h6",
      ".archives li a.title",
    ].join(", ")
  );
  for (el of elements) {
    parser.applyElement(el);
  }
});
