# MVP Launch TODO List

## Phase 1: Core Product Completion

### 1. Complete Remaining MVP Features
**Based on architecture.md roadmap - Phase 6: Polish & Launch**

#### UI/UX Polish (Mostly Complete)
- [x] Multi-language support (12 languages)
- [x] RTL support (Hebrew, Arabic)
- [x] Dark mode support
- [x] Onboarding flow
- [x] Settings screen with preferences
- [x] Error handling and edge cases
- [x] Performance optimization

#### AI Chat Enhancements
- [x] AI provider service (OpenAI - gpt-4o-mini)
- [x] Chat UI implementation
- [x] Place Recommendation cards
- [x] AI-generated chat titles
- [x] Daily Travel Tips
- [ ] Add to itinerary from chat (save AI recommendations directly)

#### Expense Splitting (Group Trips)
- [x] Rich Expenses Dashboard with charts
- [x] Add/edit expense flow
- [x] Expense confirmation via chat
- [ ] Expense splitting logic
- [ ] Balance calculations per trip member
- [ ] Settlement tracking (mark as paid)
- [ ] Settlement summary screen

### 2. Configure OpenRouter for Multiple Models
- [ ] Set up OpenRouter API integration
- [ ] Configure model selection (GPT-4, Claude, Gemini, etc.)
- [ ] Add fallback logic between models
- [ ] Implement model switching in settings (if user-facing)
- [ ] Test response quality across different models
- [ ] Set up rate limiting and cost controls

---

## Phase 2: Analytics & Monetization

### 3. Integrate Google Analytics / Firebase Analytics
- [ ] Set up Firebase project (if not already)
- [ ] Add Firebase Analytics SDK
- [ ] Define key events to track (sign_up, trip_created, ai_chat, etc.)
- [ ] Set up conversion funnels
- [ ] Create custom dashboards
- [ ] Test event tracking

### 4. Integrate RevenueCat
- [ ] Create RevenueCat account and project
- [ ] Define subscription tiers/products
- [ ] Set up products in App Store Connect & Google Play Console
- [ ] Integrate RevenueCat SDK
- [ ] Implement paywall UI
- [ ] Add subscription status checks throughout app
- [ ] Test purchase flows (sandbox)
- [ ] Set up webhooks for subscription events

---

## Phase 3: Beta Testing

### 5. Beta Testing Program
- [ ] Define beta user criteria
- [ ] Set up TestFlight (iOS) and Internal Testing (Android)
- [ ] Create feedback collection method (form, in-app, Discord)
- [ ] Recruit 10-20 beta users
- [ ] Prepare beta onboarding instructions
- [ ] Run beta for 2-4 weeks
- [ ] Collect and prioritize feedback
- [ ] Fix critical bugs before launch

---

## Phase 4: Deployment & CI/CD

### 6. Set Up CI/CD Pipeline
- [ ] Choose CI/CD platform (GitHub Actions, Codemagic, Fastlane)
- [ ] Configure automated builds
- [ ] Set up code signing (iOS certificates, Android keystore)
- [ ] Automate TestFlight/Internal Testing uploads
- [ ] Configure production deployment to App Store & Play Store
- [ ] Add automated testing to pipeline
- [ ] Set up version bumping automation
- [ ] Document deployment process

---

## Phase 5: Marketing & Launch

### 7. Create Web Landing Page
- [ ] Design landing page (hero, features, pricing, CTA)
- [ ] Choose hosting (Vercel, Netlify, etc.)
- [ ] Build responsive landing page
- [ ] Add app store badges/links
- [ ] Set up custom domain
- [ ] Add SEO meta tags
- [ ] Integrate analytics
- [ ] Add email capture form

### 8. Integrate Email Marketing
- [ ] Choose email platform (Mailchimp, SendGrid, Loops, etc.)
- [ ] Design email templates (welcome, onboarding, tips)
- [ ] Set up email capture on landing page
- [ ] Create automated email sequences
- [ ] Integrate in-app email triggers (via Supabase Edge Functions)
- [ ] Set up transactional emails (password reset, etc.)
- [ ] Ensure GDPR/CAN-SPAM compliance

### 9. Set Up Affiliate Program (RevShareCat)
- [ ] Create RevShareCat account (€19/mo starter)
- [ ] Connect RevenueCat integration
- [ ] Define commission structure (e.g., 20% per subscription)
- [ ] Set up affiliate onboarding flow
- [ ] Create unique promo codes per influencer
- [ ] Configure payout settings
- [ ] Prepare affiliate guidelines/terms
- [ ] Recruit initial influencers (5 for starter plan)
- [ ] Note: Consider upgrading to Rewardful ($49/mo) when > 5 affiliates or > $560/mo commissions

---

## Launch Checklist

- [ ] App Store listing complete (screenshots, description, keywords)
- [ ] Play Store listing complete
- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] Support email/system ready
- [ ] Social media accounts created
- [ ] Launch announcement prepared
- [ ] Press kit ready (optional)

---

## Notes

- **Priority**: Complete phases 1-3 before public launch
- **Timeline**: Set realistic deadlines for each phase
- **Resources**: Consider which tasks need external help

---

*Last updated: December 1, 2025*
