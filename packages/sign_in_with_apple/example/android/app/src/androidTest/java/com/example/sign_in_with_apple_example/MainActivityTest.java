package com.example.sign_in_with_apple_example;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.e2e.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

// No need for tests. This is just a scaffold for e2e flutter tests
@SuppressWarnings("JUnitTestCaseWithNoTests")
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
    @Rule
    public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class);
}
