from sqlalchemy import Column, DateTime, Integer, String, UniqueConstraint, func
from sqlalchemy.orm import relationship

from db import Base


class Beacon(Base):
    __tablename__ = "beacons"

    id = Column(String, primary_key=True, index=True)
    major = Column(Integer, index=True)
    minor = Column(Integer, index=True)
    location = Column(String, index=True)
    last_used = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    name = Column(String, index=True, nullable=True)

    # Relationships
    meetings = relationship("Meeting", back_populates="beacon")

    __table_args__ = (
        UniqueConstraint("id", "name", name="uq_beacon_id_name"),
    )
