<script>
  import GaCoVi from "./components/GaCoVi.svelte";
  import SettingsModal from "./components/SettingsModal.svelte";
  import {
    Header,
    HeaderNav,
    SideNav,
    SideNavItems,
    SideNavLink,
    HeaderNavItem,
  } from "carbon-components-svelte";

  import {
    Button,
    MultiSelect,
    Modal,
    Checkbox,
    FormGroup,
  } from "carbon-components-svelte";

  import { Content, Grid, Row, Column } from "carbon-components-svelte";

  import TrashCan24 from "carbon-icons-svelte/lib/TrashCan24";
  import Settings24 from "carbon-icons-svelte/lib/Settings24";

  const pilots = [
    {
      id: "AUA",
      name: "AUA - Grapevine Responses to Terroir",
      subpilots: [{ id: "default", name: "default" }],
    },
    {
      id: "INRAE",
      name: "INRAE - De la Vigne au Vin",
      subpilots: [
        { id: "default", name: "Vins Rouges et Blancs" },
        { id: "white", name: "Vins Blancs" },
        { id: "red", name: "Vins Rouges" },
      ],
    },
  ];

  let isSideNavOpen = false;

  let pilot = pilots[0];
  $: subpilot = pilot.subpilots[0];
  let or_nodes = [];
  let or_edges = [];
  let or_targets = [];

  let data = {};
  $: nodes = data.nodes ? data.nodes : [];
  let targets = [];

  let data_load = false;
  let selectedIds = [];
  let removedIds = [];
  let recoverIds = [];

  let allChecked = false;
  $: if (recoverIds.length > 0 && recoverIds.length === removedIds.length) {
    allChecked = true;
  }
  $: if (recoverIds.length === 0) {
    allChecked = false;
  }
  $: allIndeterminate = !(
    recoverIds.length == 0 || recoverIds.length == removedIds.length
  );

  let restoreModal = false;
  let settingsModal = false;

  const loadData = async () => {
    const file_name =
      subpilot.id == "default"
        ? `mvn_${pilot.id}.json`
        : `mvn_${pilot.id}_${subpilot.id}.json`;
    const res = await fetch(`/public/${file_name}`);
    const mvn = await res.json();
    or_nodes = mvn.nodes;
    or_edges = mvn.edges;
  };

  const handlePilotChange = async (pilot) => {
    data_load = false;
    await loadData();
    if (or_nodes.length > 0 && or_nodes[0].correlations.length > 0) {
      or_targets = or_nodes[0].correlations.map((c) => c.long_name);
      targets = or_targets;
    }
    selectedIds = [];
    removedIds = [];
    await filterAndOrder();
    data_load = true;
  };

  $: handlePilotChange(pilot);

  const filterAndOrder = async () => {
    let remove;
    if (recoverIds.length > 0) {
      remove = removedIds.filter((id) => !recoverIds.includes(id));
    } else {
      remove = [...removedIds, ...selectedIds];
    }

    const f_nodes = or_nodes
      .filter((n) => !remove.includes(n.id))
      .map((n) => {
        const f_correlations = n.correlations.filter((c) =>
          targets.includes(c.long_name)
        );
        return { ...n, correlations: f_correlations };
      });
    const f_edges = or_edges.filter(
      (n) => !(remove.includes(n.from) || remove.includes(n.to))
    );
    const mvn = { nodes: f_nodes, edges: f_edges };

    const res = await fetch(`/order`, {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      method: "POST",
      body: JSON.stringify({ mvn }),
    });
    const new_mvn = await res.json();
    removedIds = remove;
    data = new_mvn;
  };

  const handleApply = async (event) => {
    if (subpilot.id != event.detail.selectedSubpilot) {
      subpilot = pilot.subpilots.find(
        (sp) => sp.id == event.detail.selectedSubpilot
      );
      await loadData();
    }

    targets = event.detail.selectedTargets;
    await filterAndOrder();
    settingsModal = false;
  };
</script>

<style lang="scss" global>
  /** white theme **/
  @import "carbon-components-svelte/css/white";
</style>

{#if data_load}
  <SettingsModal
    pilotName={pilot.name}
    allTargets={or_targets}
    currentTargets={targets}
    subpilots={pilot.subpilots}
    currentSubpilot={subpilot.id}
    bind:open={settingsModal}
    on:apply={handleApply} />
{/if}

{#if data_load}
  <Modal
    size="small"
    modalHeading="Restore Features"
    modalLabel={`${pilot.id} - Feature Bin`}
    primaryButtonText="Restore"
    secondaryButtonText="Cancel"
    bind:open={restoreModal}
    on:click:button--secondary={() => {
      restoreModal = false;
    }}
    on:open={() => {}}
    on:close={() => {
      recoverIds = [];
    }}
    on:submit={async () => {
      await filterAndOrder();
      recoverIds = [];
      restoreModal = false;
    }}>
    {#if removedIds.length == 0}
      <span style="color: #c6c6c6">No removed features.</span>
    {:else}
      <FormGroup>
        <Checkbox
          id="select-all"
          checked={allChecked}
          labelText="Select all"
          indeterminate={allIndeterminate}
          on:check={({ detail }) => {
            if (detail) {
              recoverIds = removedIds.sort();
            } else recoverIds = [];
          }} />
        {#each removedIds.sort() as id}
          <div
            class="bx--form-item bx--checkbox-wrapper"
            style="margin-left: 30px;">
            <input
              type="checkbox"
              class="bx--checkbox"
              {id}
              name={id}
              bind:group={recoverIds}
              value={id} />
            <label class="bx--checkbox-label" for={id}>
              <span class="bx--checkbox-label-text">
                {or_nodes.find((n) => n.id === id).long_name}
              </span>
            </label>
          </div>
        {/each}
      </FormGroup>
    {/if}
  </Modal>
{/if}

<Header
  persistentHamburgerMenu="true"
  href="/"
  company="BigDataGrapes"
  platformName="GaCoVi"
  bind:isSideNavOpen>
  <HeaderNav>
    {#each pilots as p}
      <HeaderNavItem
        on:click={() => {
          pilot = p;
        }}
        text={p.name} />
    {/each}
  </HeaderNav>
</Header>

<SideNav bind:isOpen={isSideNavOpen}>
  <SideNavItems>
    {#each pilots as p}
      <SideNavLink
        on:click={() => {
          pilot = p;
        }}
        text={p.name} />
    {/each}
  </SideNavItems>
</SideNav>

<Content>
  <Grid>
    <Row style="margin-bottom: 1rem">
      <Column>
        <h2>
          {pilot.name}
          <Button
            on:click={() => {
              settingsModal = true;
            }}
            kind="ghost"
            size="field">
            <Settings24 fill="inherit" />
          </Button>
        </h2>
        {#if pilot.subpilots.length > 1}
          <h4>{subpilot.name}</h4>
        {/if}
      </Column>
    </Row>

    {#if data_load}
      <Row style="margin-bottom: 1rem">
        <Column sm={3} md={3} lg={4}>
          <MultiSelect
            size="xl"
            id="multiselect"
            label="Features"
            placeholder="Select Features"
            bind:selectedIds
            items={nodes.map((n) => ({ ...n, text: n.long_name }))} />
        </Column>
        <Column>
          <Button on:click={filterAndOrder}>
            <TrashCan24 fill="inherit" />
            Remove features
          </Button>
          <Button
            on:click={() => {
              restoreModal = true;
            }}
            kind="secondary">
            Restore features...
          </Button>
        </Column>
      </Row>
    {/if}
    {#if data_load && nodes.length != 0}
      <Row>
        <Column>
          <GaCoVi {data} bind:selectedIds />
        </Column>
      </Row>
    {/if}
  </Grid>
</Content>
