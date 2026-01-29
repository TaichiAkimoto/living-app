import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import * as fs from "fs";
import * as path from "path";

describe("Firestore Security Rules", () => {
  let testEnv: RulesTestEnvironment;
  const USER_ID = "testUser123";
  const OTHER_USER_ID = "otherUser456";

  beforeAll(async () => {
    // Firestore Rules を読み込み
    const rulesPath = path.resolve(__dirname, "../../firestore.rules");
    const rules = fs.readFileSync(rulesPath, "utf8");

    // テスト環境を初期化
    testEnv = await initializeTestEnvironment({
      projectId: "demo-living-test",
      firestore: {
        rules,
        host: "127.0.0.1",
        port: 8080,
      },
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  afterEach(async () => {
    await testEnv.clearFirestore();
  });

  describe("users collection", () => {
    it("should allow authenticated user to read their own document", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      await assertSucceeds(userDoc.get());
    });

    it("should deny unauthenticated user to read documents", async () => {
      const context = testEnv.unauthenticatedContext();
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      await assertFails(userDoc.get());
    });

    it("should deny user to read other user's document", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const otherUserDoc = context.firestore().collection("users").doc(OTHER_USER_ID);

      await assertFails(otherUserDoc.get());
    });

    it("should allow user to update their own document with valid fields", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      // 初期データを設定
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("users").doc(USER_ID).set({
          name: "Test User",
          emergencyContactName: "Contact",
          emergencyContactEmail: "contact@example.com",
          lastCheckIn: new Date(),
          notified: false,
        });
      });

      // 正常な更新（lastCheckIn のみ）
      await assertSucceeds(
        userDoc.update({
          lastCheckIn: new Date(),
        })
      );
    });

    it("should FAIL: prevent user from setting notified=true (server-only field)", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      // 初期データを設定
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("users").doc(USER_ID).set({
          name: "Test User",
          emergencyContactName: "Contact",
          emergencyContactEmail: "contact@example.com",
          lastCheckIn: new Date(),
          notified: false,
        });
      });

      // notified を true に変更しようとする（禁止されるべき）
      // 現在のルールでは許可されてしまう → このテストは FAIL するはず（Red phase）
      await assertFails(
        userDoc.update({
          notified: true,
        })
      );
    });

    it("should FAIL: prevent user from setting notifiedAt (server-only field)", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      // 初期データを設定
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection("users").doc(USER_ID).set({
          name: "Test User",
          emergencyContactName: "Contact",
          emergencyContactEmail: "contact@example.com",
          lastCheckIn: new Date(),
          notified: false,
        });
      });

      // notifiedAt を設定しようとする（禁止されるべき）
      // 現在のルールでは許可されてしまう → このテストは FAIL するはず（Red phase）
      await assertFails(
        userDoc.update({
          notifiedAt: new Date(),
        })
      );
    });

    it("should validate name length (1-50 characters)", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      // 空文字列は拒否
      await assertFails(
        userDoc.set({
          name: "",
          emergencyContactName: "Contact",
          emergencyContactEmail: "contact@example.com",
          lastCheckIn: new Date(),
        })
      );

      // 51文字は拒否
      await assertFails(
        userDoc.set({
          name: "a".repeat(51),
          emergencyContactName: "Contact",
          emergencyContactEmail: "contact@example.com",
          lastCheckIn: new Date(),
        })
      );
    });

    it("should validate email format", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const userDoc = context.firestore().collection("users").doc(USER_ID);

      // @ がないメールは拒否
      await assertFails(
        userDoc.set({
          name: "Test",
          emergencyContactName: "Contact",
          emergencyContactEmail: "notanemail",
          lastCheckIn: new Date(),
        })
      );
    });
  });

  describe("notificationLogs collection", () => {
    it("should deny client read access", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const logDoc = context.firestore().collection("notificationLogs").doc("log1");

      await assertFails(logDoc.get());
    });

    it("should deny client write access", async () => {
      const context = testEnv.authenticatedContext(USER_ID);
      const logDoc = context.firestore().collection("notificationLogs").doc("log1");

      await assertFails(
        logDoc.set({
          deviceId: USER_ID,
          sentTo: "test@example.com",
          status: "sent",
        })
      );
    });
  });
});
