import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "roleSelect",
    "staffContainer",
    "staffIdField",
    "staffSearchInput",
    "staffDropdown",
    "nameField",
    "emailField",
  ];
  static values = { currentUserId: Number };

  connect() {
    this.staffProfiles = [];
    this.isLoading = false;
    this.isLoaded = false;
    this.onDocumentClick = this.handleDocumentClick.bind(this);
    document.addEventListener("click", this.onDocumentClick);
    this.loadStaffProfiles();
    this.roleChanged();
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick);
  }

  roleChanged() {
    const selectedRole = this.roleSelectTarget.value;

    if (selectedRole) {
      this.checkIfStaffRole(selectedRole);
    } else {
      this.staffContainerTarget.classList.add("d-none");
      this.clearStaffSelection();
    }
  }

  checkIfStaffRole(roleId) {
    // Check if the selected role name is "staff"
    const roleOptions = this.roleSelectTarget.options;
    const selectedOption = Array.from(roleOptions).find(
      (opt) => opt.value === roleId,
    );

    if (selectedOption && selectedOption.text.toLowerCase() === "staff") {
      this.staffContainerTarget.classList.remove("d-none");
      this.loadStaffProfiles();
    } else {
      this.staffContainerTarget.classList.add("d-none");
      this.clearStaffSelection();
      this.closeDropdown();
    }
  }

  openDropdown() {
    if (this.staffContainerTarget.classList.contains("d-none")) return;

    if (this.isLoading) {
      this.staffDropdownTarget.innerHTML =
        '<div class="staff-search-empty">Loading staff names...</div>';
      this.staffDropdownTarget.classList.remove("d-none");
      return;
    }

    if (!this.isLoaded) {
      this.loadStaffProfiles();
      this.staffDropdownTarget.innerHTML =
        '<div class="staff-search-empty">Loading staff names...</div>';
      this.staffDropdownTarget.classList.remove("d-none");
      return;
    }

    this.renderDropdown(this.staffSearchInputTarget.value);
    this.staffDropdownTarget.classList.remove("d-none");
  }

  closeDropdown() {
    this.staffDropdownTarget.classList.add("d-none");
  }

  searchChanged() {
    // Typing means user is searching again, so clear previous selection.
    this.staffIdFieldTarget.value = "";
    this.clearStaffFields();

    if (this.isLoading) {
      this.staffDropdownTarget.innerHTML =
        '<div class="staff-search-empty">Loading staff names...</div>';
      this.staffDropdownTarget.classList.remove("d-none");
      return;
    }

    if (!this.isLoaded) {
      this.loadStaffProfiles();
      this.staffDropdownTarget.innerHTML =
        '<div class="staff-search-empty">Loading staff names...</div>';
      this.staffDropdownTarget.classList.remove("d-none");
      return;
    }

    this.renderDropdown(this.staffSearchInputTarget.value);
    this.staffDropdownTarget.classList.remove("d-none");
  }

  loadStaffProfiles() {
    if (this.isLoading || this.isLoaded) return;

    this.isLoading = true;

    fetch(this.dataUrl())
      .then((response) => response.json())
      .then((data) => {
        this.staffProfiles = data;
        this.isLoaded = true;
        this.syncSelectedStaff();
      })
      .catch((error) => console.error("Error loading staff profiles:", error))
      .finally(() => {
        this.isLoading = false;
      });
  }

  dataUrl() {
    const query = this.hasCurrentUserIdValue
      ? `?current_user_id=${this.currentUserIdValue}`
      : "";
    return `/staff_profiles/data.json${query}`;
  }

  renderDropdown(query = "") {
    const normalizedQuery = query.trim().toLowerCase();
    const filtered = this.staffProfiles.filter((profile) =>
      profile.fullname.toLowerCase().includes(normalizedQuery),
    );

    if (filtered.length === 0) {
      this.staffDropdownTarget.innerHTML =
        '<div class="staff-search-empty">No staff found</div>';
      return;
    }

    this.staffDropdownTarget.innerHTML = filtered
      .map(
        (profile) =>
          `<button type="button" class="staff-search-item" data-staff-id="${profile.staff_profile_id}">${profile.fullname}</button>`,
      )
      .join("");

    this.staffDropdownTarget
      .querySelectorAll(".staff-search-item")
      .forEach((item) => {
        item.addEventListener("mousedown", (event) => {
          event.preventDefault();
          const selectedId = item.dataset.staffId;
          this.selectStaffById(selectedId);
        });
      });
  }

  selectStaffById(staffId) {
    const profile = this.staffProfiles.find(
      (item) => String(item.staff_profile_id) === String(staffId),
    );
    if (!profile) return;

    this.staffIdFieldTarget.value = profile.staff_profile_id;
    this.staffSearchInputTarget.value = profile.fullname;
    this.nameFieldTarget.value = profile.fullname;
    this.emailFieldTarget.value = profile.email;
    this.closeDropdown();
  }

  syncSelectedStaff() {
    const selectedId = this.staffIdFieldTarget.value;
    if (!selectedId) return;

    const profile = this.staffProfiles.find(
      (item) => String(item.staff_profile_id) === String(selectedId),
    );
    if (!profile) return;

    this.staffSearchInputTarget.value = profile.fullname;
    this.nameFieldTarget.value = profile.fullname;
    this.emailFieldTarget.value = profile.email;
  }

  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.closeDropdown();
    }
  }

  clearStaffSelection() {
    this.staffIdFieldTarget.value = "";
    this.staffSearchInputTarget.value = "";
    this.clearStaffFields();
  }

  clearStaffFields() {
    this.nameFieldTarget.value = "";
    this.emailFieldTarget.value = "";
  }
}
