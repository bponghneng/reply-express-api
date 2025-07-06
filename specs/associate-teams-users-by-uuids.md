# Plan: Associate Teams and Users by UUIDs

This plan details the necessary steps to refactor the team/user association to use UUIDs and implement the full user registration and team creation process flow.

---


### Phase 2: Update Projections for UUID-based Associations

3.  **Update `TeamUser` Projection**:
    - **Task**: Modify `lib/reply_express/accounts/projections/team_user.ex`.
    - **Objective**:
        - Set `@primary_key false`.
        - Change `belongs_to` associations to use `team_uuid` and `user_uuid` as foreign keys, referencing the `uuid` field on the `teams` and `users` tables.

4.  **Update `Team` and `User` Projections**:
    - **Task**: Modify `lib/reply_express/accounts/projections/team.ex` and `lib/reply_express/accounts/projections/user.ex`.
    - **Objective**: Update the `many_to_many` and `has_many` associations to use the new UUID-based join keys (`team_uuid`, `user_uuid`).



