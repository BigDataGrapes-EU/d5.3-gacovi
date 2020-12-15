<script>
  import embed, { vega } from "vega-embed";
  import { onMount } from "svelte";

  export let data;
  export let selectedIds = [];

  let view;

  $: if (view) {
    view.data("nodes", []);
    view.run();
    view.data("edges", data.edges);
    view.data("nodes", data.nodes);
    view.resize().run();
  }

  $: if (view) {
    const selected = data.nodes.filter((n) => selectedIds.includes(n.id));
    view.data("selected", selected).run();
  }

  onMount(() => {
    embed("#gacovi", "./spec/spec.json", {
      actions: false,
      logLevel: vega.None, // Comment on dev
    })
      .then((res) => {
        view = res.view;
        view.addDataListener("selected", function (n, v) {
          selectedIds = v.map((v) => v.id);
        });
      })
      .catch((error) => console.log(error));
  });
</script>

<div id="gacovi" />
