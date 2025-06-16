from sqlalchemy import Column, Integer, String, Float, Boolean
from sqlalchemy.orm import relationship
from models.base import Base

class SubscriptionPlan(Base):
    __tablename__ = "subscription_plans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True)
    description = Column(String)
    price = Column(Float)
    duration_days = Column(Integer)
    is_premium = Column(Boolean, default=False)

    subscribers = relationship("UserSubscription", back_populates="plan")
