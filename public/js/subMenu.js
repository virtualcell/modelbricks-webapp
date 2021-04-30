let subMenus = document.querySelectorAll(".drop .dropTitle");
if (subMenus.length) {
  subMenus.forEach((dropdown) => {
    dropdown.addEventListener("click", (event) => {
      let target = event.target.closest(".drop").childNodes[3];
      let icon = event.target.childNodes[1];
      if (target) {
        target.classList.toggle("active");
      }
      if (icon) {
        if (icon.classList.value === "fa fa-angle-down") {
          icon.classList.value = "fa fa-angle-up";
        } else if (icon.classList.value === "fa fa-angle-up") {
          icon.classList.value = "fa fa-angle-down";
        }
      }

      console.log(f);
    });
  });
}
