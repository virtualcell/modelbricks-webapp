console.log("Hi from searchForm");
// function mascara(i) {
//   const v = i.value;

//   if (isNaN(v[v.length - 1])) {
//     // impede entrar outro caractere que não seja número
//     i.value = v.substring(0, v.length - 1);
//     return;
//   }

//   i.setAttribute("maxlength", "14");
//   if (v.length == 3 || v.length == 7) i.value += ".";
//   if (v.length == 11) i.value += "-";
// }

// function formataCPF(i) {
//   let cpf = i.value;
//   cpf = cpf.replace(/[^\d]/g, "");

//   i.value = cpf.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
// }

// @todo(myself) Give credits to the guy who made this, and make accessibility adjustments
class DataList {
  constructor(containerId, inputId, listId, options) {
    this.containerId = containerId;
    this.inputId = inputId;
    this.listId = listId;
    this.options = options;
  }

  // create(filter = "") {
  //   const list = document.getElementById(this.listId);
  //   const filterOptions = this.options.filter(
  //     (d) =>
  //       filter === "" || d.text.toLowerCase().includes(filter.toLowerCase())
  //   );
  //   if (filterOptions.length === 0) {
  //     list.classList.remove("active");
  //     filterOptions.push({
  //       value: "",
  //       text: "No value found with theses parameters.",
  //     });
  //   } else {
  //     list.classList.add("active");
  //   }

  //   list.innerHTML = filterOptions
  //     .map((o) => `<li data-value=${o.value}><span>${o.text}</span></li>`)
  //     .join("");
  // }

  addListeners(datalist) {
    const container = document.getElementById(this.containerId);
    const input = document.getElementById(this.inputId);
    const list = document.getElementById(this.listId);
    document.addEventListener("click", (e) => {
      if (!e.target.closest(`#${this.containerId}`)) {
        container.classList.remove("active");
      }
    });

    container.addEventListener("click", (e) => {
      if (e.target.id === this.inputId) {
        container.classList.add("active");
      } else if (e.target.classList.contains("datalist-icon")) {
        container.classList.toggle("active");
        input.focus();
      }

      if (container.classList.contains("active")) {
        const rect = list.getBoundingClientRect();
        if (
          !(
            rect.top >= 0 &&
            rect.bottom <=
              (window.innerHeight || document.documentElement.clientHeight)
          )
        ) {
          list.classList.add("datalist-ul--up");
        }
      }
    });

    input.addEventListener("focus", (e) => {
      container.classList.add("active");
    });

    input.addEventListener("input", (e) => {
      if (!container.classList.contains("active")) {
        container.classList.add("active");
      }

      datalist.create(input.value);
    });

    list.addEventListener("click", (e) => {
      if (e.target.nodeName.toLocaleLowerCase() === "li") {
        if (!e.target.dataset.value) return;
        input.value = e.target.innerText;
        container.classList.remove("active");
        datalist.create();
        input.setCustomValidity("");
      }
    });
  }
}

// const data = [
//   {
//     value: "1",
//     text: "all",
//   },
//   {
//     value: "2",
//     text: "public",
//   },
//   {
//     value: "3",
//     text: "shared",
//   },
//   {
//     value: "4",
//     text: "mine",
//   },
//   {
//     value: "5",
//     text: "tutorials",
//   },
//   {
//     value: "6",
//     text: "educational",
//   },
// ];

// const datalist = new DataList(
//   "datalist",
//   "datalist-input",
//   "datalist-ul",
//   data
// );

// datalist.create();
// datalist.addListeners(datalist);
