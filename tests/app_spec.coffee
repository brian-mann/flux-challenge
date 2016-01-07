describe "Flux Challenge [000]", ->
  describe "preset fixture data [00g]", ->
    beforeEach ->
      cy
        .server({delay: 500})
        .route("/dark-jedis/3616", "fixture:darth_sidious").as("getDarthSidious")
        .route("/dark-jedis/1489", "fixture:darth_vader").as("getDarthVader")
        .route("/dark-jedis/1330", "fixture:antinnis_tremayne").as("getAntinnis")
        .route("/dark-jedis/2350", "fixture:darth_plagueis").as("getDarthPlagueis")
        .route("/dark-jedis/5956", "fixture:darth_tenebrous").as("getDarthTenebrous")
        .route("/dark-jedis/1121", "fixture:darth_millennial").as("getDarthMillennial")
        .route("/dark-jedis/2942", "fixture:darth_cognus").as("getDarthCognus")
        .visit("http://localhost:8080/submissions/leoasis")

    it "loads the app [001]", ->
      cy.get("#app")

    context "initial request for jedi data [002]", ->
      it "makes first request to /dark-jedis/3616 [003]", ->
        ## make sure our server is sending back
        ## the correct data in the response body
        cy
          .wait("@getDarthSidious")
          .its("responseBody").should (body) ->
            ## we want to make multiple assertions about the body
            ## verifying both the name and the response has
            ## master + apprentice url's which is what feeds
            ## the next two requests
            expect(body.name).to.eq("Darth Sidious")
            expect(body.apprentice).to.have.property("url")
            expect(body.master).to.have.property("url")

      it "displays Darth Sidious at the top of the list [004]", ->
        cy
          .wait("@getDarthSidious")
          .get("ul.css-slots li").eq(0).should("contain", "Darth Sidious")

      it "subsequently fetches Darth Vader, Antinnis Tremayne, and disables the down button [005]", ->
        cy
          .wait("@getDarthSidious")

          ## alias the elements we're reusing
          .get(".css-button-down").as("downButton")

          ## only Darth Sidious at first
          .get("ul.css-slots li").eq(0).should("contain", "Darth Sidious")
          .get("ul.css-slots li").eq(1).should("be.empty")
          .get("ul.css-slots li").eq(2).should("be.empty")
          .get("@downButton").should("be.disabled")

          ## then Darth Vader
          .wait("@getDarthVader")
          .get("ul.css-slots li").eq(0).should("contain", "Darth Sidious")
          .get("ul.css-slots li").eq(1).should("contain", "Darth Vader")
          .get("ul.css-slots li").eq(2).should("be.empty")
          .get("@downButton").should("be.disabled")

          ## then Antinnis Tremayne
          .wait("@getAntinnis")
          .get("ul.css-slots li").eq(0).should("contain", "Darth Sidious")
          .get("ul.css-slots li").eq(1).should("contain", "Darth Vader")
          .get("ul.css-slots li").eq(2).should("contain", "Antinnis Tremayne")
          .get(".css-button-down").should("be.disabled")

    context "scrolling up [006]", ->
      beforeEach ->
        ## perform this only after we have our data
        cy
          .wait(["@getDarthSidious", "@getDarthVader", "@getAntinnis"])
          .get(".css-button-up").as("upButton")
          .get(".css-button-down").as("downButton")

      it "shifts the list up, inserts blank entries, then shifts the list down [007]", ->
        ## there is a potential race condition here where our assertions
        ## happen AFTER the data has come back in. the better way of handling
        ## this is to upgrade the server to be able to permanently 'hold' XHR's
        ## in limbo until we are ready to respond
        ##
        ## doing it the way we're doing it is fine but forces us to control the
        ## response fixture because we cannot control the delay without stubbing
        ## the response body
        cy
          ## when we click the up button our slots should be shifted down
          ## with our existing data pushed down 2 slots
          .get("@upButton").click()
          .get("ul.css-slots li").eq(0).should("be.empty")
          .get("ul.css-slots li").eq(1).should("be.empty")
          .get("ul.css-slots li").eq(2).should("contain", "Darth Sidious")
          .get("ul.css-slots li").eq(3).should("contain", "Darth Vader")
          .get("ul.css-slots li").eq(4).should("contain", "Antinnis Tremayne")

          ## now darth plagueis should be in
          .wait("@getDarthPlagueis")
          .get("ul.css-slots li").eq(1).should("contain", "Darth Plagueis")

          ## now Darth Tenebrous
          .wait("@getDarthTenebrous")
          .get("ul.css-slots li").eq(0).should("contain", "Darth Tenebrous")

          ## now go get next two darth's
          .get("@upButton").click()

          .get("ul.css-slots li").eq(0).should("be.empty")
          .get("ul.css-slots li").eq(1).should("be.empty")
          .get("ul.css-slots li").eq(2).should("contain", "Darth Tenebrous")
          .get("ul.css-slots li").eq(3).should("contain", "Darth Plagueis")
          .get("ul.css-slots li").eq(4).should("contain", "Darth Sidious")

          ## now darth plagueis should be in
          .wait("@getDarthMillennial")
          .get("ul.css-slots li").eq(1).should("contain", "Darth Millennial")

          ## now Darth Tenebrous
          .wait("@getDarthCognus")
          .get("ul.css-slots li").eq(0).should("contain", "Darth Cognus")

    context "cancelling stale requests [008]", ->
      beforeEach ->
        ## perform this only after we have our data
        cy
          .wait(["@getDarthSidious", "@getDarthVader", "@getAntinnis"])
          .get(".css-button-up").as("upButton")
          .get(".css-button-down").as("downButton")

      it "cancels requests for Darth Millennial and Darth Cognus [009]", ->
        cy
          ## click up twice which should fetch 4 darths
          .get("@upButton").click().click()

          ## wait for the request for darth millennial
          ## to go out which is the 3rd request
          .wait("@getDarthMillennial.request")

          ## then click down which should cancel this request
          .get("@downButton").click()

          .get("@getDarthMillennial").its("aborted").should("be.true")

    context "when home world matches dark jedi via new rows [00a]", ->
      it "highlights dark jedi in red [00b]"

      it "disables up/down arrows [00c]"

    context "when home world matches dark jedi when planet indicator changes [00d]", ->
      it "highlights dark jedi in red [00e]"

      it "disables up/down arrows until it no longer matches [00f]"

  describe "controlled fixture data [00k]", ->
    it "disables down when last known sith has no apprentice [00i]", ->
      cy.fixture("darth_sidious").then (sidious) ->
        sidious.apprentice = null

        cy
          .server()
          .route("/dark-jedis/3616", sidious).as("getDarthSidious")
          .visit("http://localhost:8080/submissions/abaran")
          .get(".css-button-up").should("not.be.disabled")
          .get(".css-button-down").should("be.disabled")

    it "disables up if the first known sith has no master [00j]", ->
      cy.fixture("darth_sidious").then (sidious) ->
        sidious.master = null

        cy
          .server()
          .route("/dark-jedis/3616", sidious).as("getDarthSidious")
          .visit("http://localhost:8080/submissions/abaran")
          .get(".css-button-up").should("be.disabled")
          .get(".css-button-down").should("not.be.disabled")
