<script>
  import { createEventDispatcher } from "svelte";
  import {
    Modal,
    FormGroup,
    RadioButtonGroup,
    RadioButton,
  } from "carbon-components-svelte";

  export let open;
  export let pilotName;
  //  Target
  export let allTargets;
  export let currentTargets;
  let selectedTargets = [];
  //  Subpilot
  export let subpilots;
  export let currentSubpilot;
  let selectedSubpilot = currentSubpilot;

  const dispatch = createEventDispatcher();

  function apply() {
    dispatch("apply", {
      selectedTargets: selectedTargets,
      selectedSubpilot: selectedSubpilot,
    });
  }
</script>

<Modal
  size="small"
  modalHeading="Settings"
  modalLabel={`${pilotName}`}
  primaryButtonText="Apply"
  secondaryButtonText="Cancel"
  bind:open
  on:click:button--secondary={() => {
    open = false;
  }}
  on:open={() => {
    selectedTargets = currentTargets;
    selectedSubpilot = currentSubpilot;
  }}
  on:close={() => {}}
  on:submit={apply}>
  {#if subpilots.length > 1}
    <FormGroup legendText="Select Dataset">
      <RadioButtonGroup bind:selected={selectedSubpilot}>
        {#each subpilots as subpilot}
          <RadioButton
            value={subpilot.id}
            id={subpilot.id}
            labelText={subpilot.name} />
        {/each}
      </RadioButtonGroup>
    </FormGroup>
  {/if}
  {#if allTargets.length > 0}
    <fieldset class="bx--fieldset">
      <legend class="bx--label">Target Variables</legend>
      {#each allTargets as target}
        <div class="bx--form-item bx--checkbox-wrapper">
          <input
            type="checkbox"
            class="bx--checkbox"
            id={target}
            name={target}
            bind:group={selectedTargets}
            value={target} />
          <label class="bx--checkbox-label" for={target}>
            <span class="bx--checkbox-label-text">{target}</span>
          </label>
        </div>
      {/each}
    </fieldset>
  {/if}
</Modal>
