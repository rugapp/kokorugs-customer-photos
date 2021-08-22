module Form = {
  module Label = %styled.label(`
    font-size: 1rem;
    line-height: 1.5rem;
    display: block;
    margin-top: 2rem;
    cursor: pointer;

    strong {
      display: block;
    }

    input {
      font-size: 1rem;
      line-height: 2rem;
      display: block;
      height: 3rem;
      width: 80%;
      padding: 0.5rem;
      box-sizing: border-box;
      border-radius: 0.25rem;
      border: 1px solid black;
    }
  `)

  type button = Primary | Secondary
  module Button = %styled.button(
    (~variation) => [
      %css("display: block"),
      %css("font-size: 1rem"),
      switch variation {
      | Primary => %css("line-height: 3rem")
      | Secondary => %css("line-height: 2rem")
      },
      switch variation {
      | Primary => %css("padding: 0.5rem 2rem")
      | Secondary => %css("padding: 0.5rem 1rem")
      },
      %css("box-sizing: border-box"),
      %css("border: none"),
      %css("cursor: pointer"),
      %css("margin-top: 2rem"),
      %css("border-radius: 0.25rem"),
      switch variation {
      | Primary => %css("background-color: dodgerblue")
      | Secondary => %css("background-color: mediumslateblue")
      },
      %css("color: white"),
    ]
  )
}

module Nav = %styled.nav(`
  display: flex;
  flex-wrap: wrap;

  a, button {
    border: 0;
    border-radius: 0.5rem;
    padding: 0.5rem;
    margin-right: 0.5rem;
    margin-bottom: 0.5rem;
    background-color: #efefef;
  }

  a {
    color: blue;
    text-decoration: underline;

    &.active {
      color: inherit;
      text-decoration: none;
      background-color: antiquewhite;
    }
  }
`)

module Invoice = %styled.div(`
  margin-top: 2rem;

  header {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    justify-content: space-between;
  }

  section {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;

    a {
      flex: 0 0 49%;
      margin-bottom: 2rem;
      text-align: center;
      text-decoration: none;

      img {
        width: 100%;

        &.duplicate {
          opacity: 0.3;
        }

        &.duplicate + .error {
          display: block;
        }
      }

      .error {
        display: none;
        color: black;
      }
    } 
  }
`)
